import 'package:flutter/material.dart';

class aboutPage extends StatefulWidget {
  const aboutPage({super.key});

  @override
  State<aboutPage> createState() => _aboutPageState();
}

class _aboutPageState extends State<aboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('About Us', style: TextStyle(
              fontSize: 16,
            ),),
            IconButton(
              onPressed: () {
                // Your onPressed logic here
              },
              icon: Image.asset(
                'assets/working.png',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage('assets/about.jpg'), // Replace with your image asset path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('About Credex', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.grey,),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Text('Leading global digital product engineering and IT services company', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.black,),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Text('Credex Technology is a leading global digital product engineering information technology services company'
                  'We design and build innovative products, platforms and digital experiences fo our clients, hlping them to successfully envisage the future and accelerate their transition into tomorrow digital world.'
                  'Credex technology offers a comprehensive portfolio of services in three integerated areas:'
                , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey,),),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Your onPressed logic here
                      },
                      icon: Image.asset(
                        'assets/verify.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    Text('Digital Product Engineering', style: TextStyle(fontSize: 12, color: Colors.black),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Your onPressed logic here
                      },
                      icon: Image.asset(
                        'assets/verify.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    Text('Buisness Experience Transformation', style: TextStyle(fontSize: 12, color: Colors.black),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Your onPressed logic here
                      },
                      icon: Image.asset(
                        'assets/verify.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    Text('Technology Innovation and Engineering', style: TextStyle(fontSize: 12, color: Colors.black),)
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
