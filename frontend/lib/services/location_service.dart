import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _errorMessage;
  bool _permissionGranted = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get permissionGranted => _permissionGranted;

  LocationService() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _checkPermissions();
    if (_permissionGranted) {
      await _getCurrentLocation();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setError('Location services are disabled. Please enable them in settings.');
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setError('Location permissions are permanently denied. Please enable them in settings.');
        return;
      }

      _permissionGranted = true;
      _setError(null);
    } catch (e) {
      _setError('Failed to check location permissions: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_permissionGranted) {
      await _checkPermissions();
      if (!_permissionGranted) return;
    }

    _setLoading(true);
    
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      _currentPosition = position;
      
      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to get location: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Format address as "City, State"
        String city = place.locality ?? place.subAdministrativeArea ?? '';
        String state = place.administrativeArea ?? '';
        
        if (city.isNotEmpty && state.isNotEmpty) {
          _currentAddress = '$city, $state';
        } else if (city.isNotEmpty) {
          _currentAddress = city;
        } else if (state.isNotEmpty) {
          _currentAddress = state;
        } else {
          _currentAddress = 'Location detected';
        }
      }
    } catch (e) {
      print('Error getting address: $e');
      _currentAddress = 'Location detected';
    }
  }

  Future<void> refreshLocation() async {
    await _getCurrentLocation();
  }

  Future<void> requestLocationPermission() async {
    await _checkPermissions();
    if (_permissionGranted) {
      await _getCurrentLocation();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get formatted location for display
  String getDisplayLocation() {
    if (_isLoading) return 'Detecting location...';
    if (_errorMessage != null) return 'Location unavailable';
    if (_currentAddress != null) return _currentAddress!;
    return 'Location unavailable';
  }

  // Get coordinates for backend/agent usage
  Map<String, double>? getCoordinates() {
    if (_currentPosition != null) {
      return {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
      };
    }
    return null;
  }

  // Get complete location data for agents
  Map<String, dynamic> getLocationData() {
    return {
      'address': _currentAddress,
      'coordinates': getCoordinates(),
      'timestamp': DateTime.now().toIso8601String(),
      'accuracy': _currentPosition?.accuracy,
    };
  }
}
