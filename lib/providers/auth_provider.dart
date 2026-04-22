import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/cloudinary_config.dart';

enum UserRole { admin, staff, none }

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false,
  );

  UserRole _role = UserRole.none;
  bool _isLoading = false;
  String? _email;
  String? _fullName;
  String? _photoUrl;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      try {
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', session.user.id)
            .single();

        final String actualRole = profile['role'] ?? 'user';
        if (actualRole == 'admin' || actualRole == 'staff') {
          _role = actualRole == 'admin' ? UserRole.admin : UserRole.staff;
          _email = session.user.email;
          _fullName = profile['full_name'];
          _photoUrl = profile['photo_url'];
          notifyListeners();
        } else {
          await _supabase.auth.signOut();
        }
      } catch (e) {
        // Session might be invalid or profile missing
      }
    }
  }

  UserRole get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _role != UserRole.none;
  String? get email => _email;
  String? get fullName => _fullName;
  String? get photoUrl => _photoUrl;

  Future<void> login(
    UserRole expectedRole,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Authenticate with Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Authentication failed';
      }

      // 2. Fetch profile and role from 'profiles' table
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      final String actualRole = profile['role'] ?? 'user';
      final String name = profile['full_name'] ?? 'Admin';

      // 3. Verify if user has admin or staff role
      if (actualRole != 'admin' && actualRole != 'staff') {
        await _supabase.auth.signOut();
        throw 'Access denied: You do not have administrative privileges.';
      }

      // 4. Update state
      _role = actualRole == 'admin' ? UserRole.admin : UserRole.staff;
      _email = email;
      _fullName = name;
      _photoUrl = profile['photo_url'];
    } catch (e) {
      _role = UserRole.none;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginStaff(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('staff_members')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response == null) {
        throw 'Invalid username or password';
      }

      if (response['status'] != 'Active') {
        throw 'Your account is ${response['status']}';
      }

      _role = UserRole.staff;
      _email = username;
      _fullName = response['name'];
      _photoUrl = response['photo_url'];

      // Attempt anonymous sign-in to Supabase to provide a session for RLS policies
      try {
        await _supabase.auth.signInAnonymously();
      } catch (e) {
        debugPrint('Anonymous sign-in failed: $e');
      }
    } catch (e) {
      _role = UserRole.none;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_role == UserRole.admin) {
        await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      } else if (_role == UserRole.staff) {
        await _supabase
            .from('staff_members')
            .update({'password': newPassword})
            .eq('username', _email!);
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? fullName, String? imagePath}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? newPhotoUrl = _photoUrl;

      // 1. Upload to Cloudinary if imagePath is provided
      if (imagePath != null) {
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(imagePath, folder: 'profile_pictures'),
        );
        newPhotoUrl = response.secureUrl;
      }

      final user = _supabase.auth.currentUser;

      if (_role == UserRole.admin && user != null) {
        // Update Admin Profile in Supabase 'profiles' table
        final Map<String, dynamic> updateData = {
          'full_name': fullName ?? _fullName,
        };
        if (imagePath != null) updateData['photo_url'] = newPhotoUrl;

        await _supabase.from('profiles').update(updateData).eq('id', user.id);

        _fullName = fullName ?? _fullName;
        _photoUrl = newPhotoUrl;
      } else if (_role == UserRole.staff) {
        final Map<String, dynamic> updateData = {'name': fullName ?? _fullName};
        if (imagePath != null) updateData['photo_url'] = newPhotoUrl;

        await _supabase
            .from('staff_members')
            .update(updateData)
            .eq('username', _email!);

        _fullName = fullName ?? _fullName;
        _photoUrl = newPhotoUrl;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _role = UserRole.none;
    _email = null;
    _fullName = null;
    _photoUrl = null;
    notifyListeners();
  }
}
