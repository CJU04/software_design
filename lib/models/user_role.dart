enum UserRole {
  admin,
  petOwner,
  staff,
  veterinarian,
}

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.petOwner:
        return 'petOwner';
      case UserRole.staff:
        return 'staff';
      case UserRole.veterinarian:
        return 'veterinarian';
    }
  }

  static UserRole? fromValue(String? value) {
    if (value == null) return null;

    final normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'admin':
        return UserRole.admin;

      // Support both spec format and common variants.
      case 'pet_owner':
      case 'petowner':
      case 'pet-owner':
      case 'petowner':
        return UserRole.petOwner;

      case 'staff':
        return UserRole.staff;

      case 'veterinarian':
      case 'vet':
      case 'veterninarian': // tolerate common misspell
        return UserRole.veterinarian;

      default:
        return null;
    }
  }

}

