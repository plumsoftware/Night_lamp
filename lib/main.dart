import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:async';
import 'package:wakelock/wakelock.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

void main() {
  runApp(const MyApp());
}

Color selectedColor = const Color(0xFF64c5fc);
var selectedRadio = 10;
var selectedMusic = 0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ночник',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const MyHomePage(title: 'Ночник'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var currentIndex = 0;
  var timeLeft = 1;

  @override
  void initState() {
    super.initState();
    MobileAds.initialize();
  }

  void startTimer() {
    Wakelock.disable();
    Duration duration = const Duration();
    if (selectedRadio > 0) {
      switch (timeLeft) {
        case 1:
          duration = const Duration(minutes: 10);
          break;
        case 2:
          duration = const Duration(minutes: 30);
          break;
        case 3:
          duration = const Duration(hours: 1);
          break;
        case 4:
          duration = const Duration(hours: 2);
          break;
      }
      Timer.periodic(duration, (timer) {
        setState(() {
          Wakelock.enable();
          print(timer.tick.toString());
          timer.cancel();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    startTimer();
    return Scaffold(
      backgroundColor: selectedColor,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: AdWidget(
            bannerAd: BannerAd(
          adUnitId: 'R-M-2266303-1',
          adSize: const AdSize.sticky(width: 320),
          adRequest: const AdRequest(),
          onAdLoaded: () {
            /* Do something */
          },
          onAdFailedToLoad: (error) {
            print(error);
          },
        )),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(displayWidth * .05),
        height: displayWidth * .155,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          borderRadius: BorderRadius.circular(50),
        ),
        child: ListView.builder(
          itemCount: 4,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
          itemBuilder: (context, index) => InkWell(
            onTap: () {
              setState(() {
                currentIndex = index;
                HapticFeedback.lightImpact();

                if (currentIndex == 1) {
                  pickColor(context);
                } else if (currentIndex == 2) {
                  pickTime(context);
                } else if (currentIndex == 3) {
                  pickMusic(context);
                }
              });
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  width: index == currentIndex
                      ? displayWidth * .32
                      : displayWidth * .18,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.fastLinearToSlowEaseIn,
                    height: index == currentIndex ? displayWidth * .12 : 0,
                    width: index == currentIndex ? displayWidth * .32 : 0,
                    decoration: BoxDecoration(
                      color: index == currentIndex
                          ? selectedColor.withOpacity(.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  width: index == currentIndex
                      ? displayWidth * .31
                      : displayWidth * .18,
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            width:
                                index == currentIndex ? displayWidth * .1 : 0,
                          ),
                          AnimatedOpacity(
                            opacity: index == currentIndex ? 1 : 0,
                            duration: const Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            child: Text(
                              index == currentIndex ? listOfStrings[index] : '',
                              style: TextStyle(
                                color: selectedColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            width:
                                index == currentIndex ? displayWidth * .03 : 20,
                          ),
                          Icon(
                            listOfIcons[index],
                            size: displayWidth * .076,
                            color: index == currentIndex
                                ? selectedColor
                                : Colors.black26,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<IconData> listOfIcons = [
    Icons.home_outlined,
    Icons.palette_outlined,
    Icons.timer_outlined,
    Icons.music_note_outlined,
  ];
  List<String> listOfStrings = [
    'Ночник',
    'Цвета',
    'Таймер',
    'Музыка',
  ];
  List<String> listOfTrackNames = ["Hotel","Мелодии луны", "Приход ночи", "Прохлада и чайки"];

  var audioPlayer = AudioPlayer();

  void pickColor(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Выберите цвет"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildColorPicker(),
                TextButton(
                  child: const Text("ВЫБРАТЬ", style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    setState(() {
                      currentIndex = 0;
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            )),
      );

  void pickTime(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Установите таймер"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Radio(
                            value: 10,
                            groupValue: selectedRadio,
                            onChanged: (value) {
                              setState(() {
                                selectedRadio = value!;
                                currentIndex = 0;
                                timeLeft = 1;
                                Navigator.of(context).pop();
                                startTimer();
                              });
                            }),
                        const Text("10 минут", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Radio(
                            value: 30,
                            groupValue: selectedRadio,
                            onChanged: (value) {
                              setState(() {
                                selectedRadio = value!;
                                currentIndex = 0;
                                timeLeft = 2;
                                Navigator.of(context).pop();
                                startTimer();
                              });
                            }),
                        const Text("30 минут", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Radio(
                            value: 60,
                            groupValue: selectedRadio,
                            onChanged: (value) {
                              setState(() {
                                selectedRadio = value!;
                                currentIndex = 0;
                                timeLeft = 3;
                                Navigator.of(context).pop();
                                startTimer();
                              });
                            }),
                        const Text("1 час", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Radio(
                            value: 120,
                            groupValue: selectedRadio,
                            onChanged: (value) {
                              setState(() {
                                selectedRadio = value!;
                                currentIndex = 0;
                                timeLeft = 4;
                                Navigator.of(context).pop();
                                startTimer();
                              });
                            }),
                        const Text("2 часа", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Radio(
                            value: -1,
                            groupValue: selectedRadio,
                            onChanged: (value) {
                              setState(() {
                                selectedRadio = value!;
                                currentIndex = 0;
                                Navigator.of(context).pop();
                                timeLeft = -1;
                                startTimer();
                              });
                            }),
                        const Text("бесконечно",
                            style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                // TextButton(
                //   child: const Text("ВЫБРАТЬ", style: TextStyle(fontSize: 20)),
                //   onPressed: () {
                //     setState(() {
                //       currentIndex = 0;
                //       Navigator.of(context).pop();
                //     });
                //   },
                // ),
              ],
            ),
          ));

  void pickMusic(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Установить музыку"),
          content: SizedBox(
            height: 400,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: listOfTrackNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(listOfTrackNames[index]),
                  onTap: () async {
                    String name = "";
                    switch(index){
                      case 0:
                        name = "toby_fox_hotel.mp3";
                        break;
                      case 1:
                        name = "moon.mp3";
                        break;
                      case 2:
                        name = "night_come.mp3";
                        break;
                      case 3:
                        name = "cold_and_birds.mp3";
                        break;
                    }

                    await audioPlayer.stop();
                    // await audioPlayer.setSource(AssetSource("toby_fox_hotel.mp3"));
                    await audioPlayer.play(AssetSource(name));
                    // await audioPlayer.resume();
                  },
                  leading: const Icon(Icons.music_note_outlined),
                );
              },
              shrinkWrap: true,
            ),
          )));

  Widget buildColorPicker() => ColorPicker(
        pickerColor: selectedColor,
        onColorChanged: (color) => selectedColor = color,
        enableAlpha: false,
        showLabel: false,
      );
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF00658D),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFC6E7FF),
  onPrimaryContainer: Color(0xFF001E2D),
  secondary: Color(0xFF4F616D),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD2E5F4),
  onSecondaryContainer: Color(0xFF0A1D28),
  tertiary: Color(0xFF62597C),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFE8DDFF),
  onTertiaryContainer: Color(0xFF1E1735),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFCFCFF),
  onBackground: Color(0xFF191C1E),
  surface: Color(0xFFFCFCFF),
  onSurface: Color(0xFF191C1E),
  surfaceVariant: Color(0xFFDDE3EA),
  onSurfaceVariant: Color(0xFF41484D),
  outline: Color(0xFF71787E),
  onInverseSurface: Color(0xFFF0F1F3),
  inverseSurface: Color(0xFF2E3133),
  inversePrimary: Color(0xFF82CFFF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF00658D),
  outlineVariant: Color(0xFFC1C7CE),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF82CFFF),
  onPrimary: Color(0xFF00344B),
  primaryContainer: Color(0xFF004C6B),
  onPrimaryContainer: Color(0xFFC6E7FF),
  secondary: Color(0xFFB6C9D8),
  onSecondary: Color(0xFF21333E),
  secondaryContainer: Color(0xFF374955),
  onSecondaryContainer: Color(0xFFD2E5F4),
  tertiary: Color(0xFFCCC1E9),
  onTertiary: Color(0xFF332C4B),
  tertiaryContainer: Color(0xFF4A4263),
  onTertiaryContainer: Color(0xFFE8DDFF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF191C1E),
  onBackground: Color(0xFFE2E2E5),
  surface: Color(0xFF191C1E),
  onSurface: Color(0xFFE2E2E5),
  surfaceVariant: Color(0xFF41484D),
  onSurfaceVariant: Color(0xFFC1C7CE),
  outline: Color(0xFF8B9198),
  onInverseSurface: Color(0xFF191C1E),
  inverseSurface: Color(0xFFE2E2E5),
  inversePrimary: Color(0xFF00658D),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF82CFFF),
  outlineVariant: Color(0xFF41484D),
  scrim: Color(0xFF000000),
);
