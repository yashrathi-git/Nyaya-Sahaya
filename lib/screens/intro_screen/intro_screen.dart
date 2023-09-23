import 'package:flutter/material.dart';
import 'package:law/screens/login/login_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (value) {
              setState(() {
                onLastPage = value == 2;
              });
            },
            controller: _controller,
            children: [
              buildIntroductionPage(),
              buildClientFeaturesPage(),
              buildLawyerFeaturesPage(),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: const Text(
                      "Back",
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                  ),
                  GestureDetector(
                    child: Text(
                      onLastPage ? "Done" : "Next",
                      style: const TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      if (onLastPage) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIntroductionPage() {
    return Container(
      color: Colors.blueAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Welcome to Nyaya Sahaya",
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/law.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Empowering Undertrial Prisoners",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Nyaya Sahaya is here to provide you with vital support during your legal journey.",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClientFeaturesPage() {
    return Container(
      color: Colors.orangeAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Client Features",
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/profile.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Access Client Features",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildBulletPoint("Find and connect with lawyers."),
                    buildBulletPoint("Track your case history."),
                    buildBulletPoint("Get legal advice and support."),
                    buildBulletPoint("Receive updates on your case."),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLawyerFeaturesPage() {
    return Container(
      color: Colors.greenAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Lawyer Features",
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/lawyer.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Unlock Lawyer Features",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildBulletPoint("Stay updated on legal news."),
                    buildBulletPoint("File and manage cases."),
                    buildBulletPoint(
                        "Connect with clients and provide support."),
                    buildBulletPoint("Access legal resources and documents."),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
