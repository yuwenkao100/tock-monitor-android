import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// 设置屏幕
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              const ListTile(
                title: Text('外观设置'),
                subtitle: Text('主题和显示选项'),
              ),
              ListTile(
                title: const Text('深色模式'),
                subtitle: const Text('切换应用主题'),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  onChanged: (ThemeMode? mode) {
                    if (mode != null) {
                      settings.setThemeMode(mode);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('跟随系统'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('浅色'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('深色'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const ListTile(
                title: Text('通知设置'),
                subtitle: Text('推送和提醒选项'),
              ),
              SwitchListTile(
                title: const Text('启用通知'),
                subtitle: const Text('接收股票信号提醒'),
                value: settings.enableNotifications,
                onChanged: settings.setEnableNotifications,
              ),
              SwitchListTile(
                title: const Text('自动刷新'),
                subtitle: const Text('定期更新股票数据'),
                value: settings.enableAutoRefresh,
                onChanged: settings.setEnableAutoRefresh,
              ),
              const Divider(),
              const ListTile(
                title: Text('关于应用'),
                subtitle: Text('版本信息和帮助'),
              ),
              ListTile(
                title: const Text('版本'),
                subtitle: const Text('1.0.0'),
                trailing: const Icon(Icons.info_outline),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: '股票监控',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.trending_up),
                    children: const [
                      Text('专业的股票技术分析工具'),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
