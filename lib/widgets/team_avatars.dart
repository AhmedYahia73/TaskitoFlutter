import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';

class TeamAvatars extends ConsumerWidget {
  final FutureProvider<List<UserModel>> provider;
  final int maxAvatars;

  const TeamAvatars({
    super.key,
    required this.provider,
    this.maxAvatars = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(provider);

    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) return const SizedBox.shrink();

        final displayUsers = users.take(maxAvatars).toList();
        final extraCount = users.length - displayUsers.length;

        return GestureDetector(
          onTap: () => _showUsersBottomSheet(context, users),
          child: SizedBox(
            height: 32,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < displayUsers.length; i++)
                  Align(
                    widthFactor: 0.7,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundImage: displayUsers[i].image != null && displayUsers[i].image!.isNotEmpty
                            ? NetworkImage('${ApiService.baseUrl}/${displayUsers[i].image}')
                            : null,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: displayUsers[i].image == null || displayUsers[i].image!.isEmpty
                            ? Text(
                                displayUsers[i].name.isNotEmpty ? displayUsers[i].name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                  ),
                if (extraCount > 0)
                  Align(
                    widthFactor: 0.7,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          '+$extraCount',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade800, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 60,
        height: 32,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (err, _) => const Icon(Icons.error_outline, size: 20, color: Colors.red),
    );
  }

  void _showUsersBottomSheet(BuildContext context, List<UserModel> users) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Team Members (${users.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.image != null && user.image!.isNotEmpty
                            ? NetworkImage('${ApiService.baseUrl}/${user.image}')
                            : null,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: user.image == null || user.image!.isEmpty
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white),
                              )
                            : null,
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user.role),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
