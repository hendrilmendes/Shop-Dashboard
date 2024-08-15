import 'package:dashboard/theme/theme.dart';
import 'package:flutter/material.dart';

class ThemeSettings extends StatelessWidget {
  final ThemeModel themeModel;

  const ThemeSettings({
    super.key,
    required this.themeModel,
  });

  void _showThemeDialog(BuildContext context, ThemeModel themeModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Escolha o Tema"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          themeModel.changeThemeMode(ThemeModeType.light);
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Radio(
                            activeColor: Colors.blue,
                            value: ThemeModeType.light,
                            groupValue: themeModel.themeMode,
                            onChanged: (value) {
                              setState(() {
                                themeModel.changeThemeMode(value!);
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const Text("Tema Claro"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          themeModel.changeThemeMode(ThemeModeType.dark);
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Radio(
                            activeColor: Colors.blue,
                            value: ThemeModeType.dark,
                            groupValue: themeModel.themeMode,
                            onChanged: (value) {
                              setState(() {
                                themeModel.changeThemeMode(value!);
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const Text("Tema Escuro"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          themeModel.changeThemeMode(ThemeModeType.system);
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Radio(
                            activeColor: Colors.blue,
                            value: ThemeModeType.system,
                            groupValue: themeModel.themeMode,
                            onChanged: (value) {
                              setState(() {
                                themeModel.changeThemeMode(value!);
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const Text("Padrão do Sistema"),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Tema"),
      subtitle: const Text("Escolha o tema que mais combina com você"),
      onTap: () {
        _showThemeDialog(context, themeModel);
      },
    );
  }
}
