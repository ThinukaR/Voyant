import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voyant/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voyant/components/badge_build.dart';
import 'package:voyant/components/quest_display_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    const bgColor = Color.fromARGB(255, 0, 0, 1);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text('User Profile'),
        centerTitle: true,
      ),
      body: SafeArea( //ensures that padding will be applied to avoid UI from overlaping with device notches or other features 
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const HeadSection(),
            const SizedBox(height: 24),
            const Stats(),
          ],
        ),
      ),
    );
  }
}

// Section for user's name and pfp 
class HeadSection extends StatelessWidget {
  const HeadSection({super.key});


@override
Widget build(BuildContext context) {
  final authState = context.watch<AuthenticationBloc>().state;
  final user = authState.user;

  //if the user's username is empty or not set, the placeholder will be Voyager
  final usernameDisplay = user?.username.isEmpty ?? true ? 'Voyager' : user!.username;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color:  Color(0xFF12121A),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [ const CircleAvatar( //Circle avatar widget to create the users profile picture
          radius: 25,
          backgroundColor: Colors.deepPurpleAccent,
          child: Icon(Icons.person, color: Colors.white),
         ),
        const SizedBox(width: 16),
          Expanded(child: Column //prevents issues that can pop up when too much text is added 
          (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usernameDisplay,
                style: const TextStyle (fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white )
                ),
                const Text('I am new here !', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          ),
          //implementation of the logout button through profile 
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent), //the standard logout icon 
            onPressed: ()=> context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested()), 
            )
      ],
      )
  );
}
}

class Stats extends StatelessWidget {
  const Stats({super.key});

  @override
  Widget build(BuildContext context) {
    return Column (
      crossAxisAlignment: CrossAxisAlignment.start, //stops content from being centered or misaligned 
      children: [
        const Text("Achievements", style: TextStyle(color: Colors.white, fontSize : 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap (
          spacing: 10,
          children: const [
            BadgeBuild(label: 'Conquered Ghosts'),
            BadgeBuild(label: 'Speedrunners'),
          ],
        ),
        const SizedBox(height: 30),
        const Text("Completed Quests",style: TextStyle(color: Colors.white, fontSize : 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const QuestDisplaySection(),
      ],
    );
  }
}

//Todo - building the badge build as reusable components 
//Todo - building quest displaybox to display the quests properly 