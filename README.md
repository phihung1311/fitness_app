# fitness_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.




// final valid = _formKey.currentState?.validate() ?? false;
// if (!valid) return;
// context.read<LoginBloc>().add(
//       LoginSubmitted(
//         email: _emailController.text,
//         password: _passwordController.text,
//       ),
//     );

//Them buton kế bên appbar
IconButton(
icon: const Icon(
Icons.star_rounded,
color: Colors.white,
),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ExerciseFavoritesScreen(),
),
);
},
tooltip: 'Yêu thích',
),
hoặc
// actions: [
//   IconButton(
//     icon: const Icon(Icons.settings, color: Colors.white,),
//     onPressed: ()=> Navigator.of(context).pushNamed(AdminAddFoodScreen.routeName)
//   ),
//   const SizedBox(width: ,)
// ],
class _Identity extends StatelessWidget {
const _Identity({required this.name, required this.email});

final String? name;
final String? email;

@override
Widget build(BuildContext context) {
String _getDisplayName() {
if (name != null && name!.trim().isNotEmpty) {
return name!.trim().split(' ').last;
}
return 'Bạn';
}

    String _getInitialLetter() {
      final displayName = _getDisplayName();
      if (displayName.isNotEmpty) {
        return displayName[0].toUpperCase();
      }
      return 'B';
    }

    return Column(
      children: [
        // Avatar tròn với chữ cái đầu
        CircleAvatar(
          radius: 50, // Kích thước lớn, nổi bật
          backgroundColor: const Color(0xFF52C41A).withOpacity(0.2), // Nền xanh lá nhạt
          child: Text(
            _getInitialLetter(),
            style: const TextStyle(
              color: Color(0xFF52C41A),
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name ?? 'Chưa có tên',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          email ?? '---',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
}
}