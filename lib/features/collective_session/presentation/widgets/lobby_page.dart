import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/palette.dart';
import '../bloc/collective_session_bloc.dart';
import '../../domain/entities/tbp_session.dart';
import 'package:tbp_v2/l10n/app_localizations.dart'; // Added import

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final _codeController = TextEditingController();



// ...

  Future<void> _showCreateDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TbpPalette.white,
        title: Text(l10n.createNewRoom, style: const TextStyle(color: TbpPalette.darkViolet, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.roomName,
            hintText: l10n.roomNameHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: const TextStyle(color: TbpPalette.darkViolet)),
          ),
          ElevatedButton(
             onPressed: () {
               if (nameController.text.isNotEmpty) {
                 context.read<CollectiveSessionBloc>().add(CreateRoomRequested(nameController.text));
                 Navigator.pop(ctx);
               }
             },
             style: ElevatedButton.styleFrom(backgroundColor: TbpPalette.darkViolet, foregroundColor: TbpPalette.white),
             child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by parent
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        label: Text(l10n.createRoom, style: const TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: TbpPalette.lilac,
        foregroundColor: TbpPalette.darkViolet,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               const SizedBox(height: 32),
               // Logo / Header
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                  color: TbpPalette.darkViolet,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.chooseRoomToJoin,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: TbpPalette.darkViolet.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Enter Code Section (Compact)
              Row(
                children: [
                   Expanded(
                     child: TextField(
                       controller: _codeController,
                       decoration: InputDecoration(
                         hintText: l10n.enterCodeHint,
                         filled: true,
                         fillColor: Colors.white.withValues(alpha: 0.8),
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                       ),
                       textCapitalization: TextCapitalization.characters,
                       style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                     ),
                   ),
                   const SizedBox(width: 8),
                   IconButton.filled(
                     onPressed: () {
                        final code = _codeController.text.trim();
                        if (code.length >= 4) {
                           context.read<CollectiveSessionBloc>().add(JoinRoomRequested(code));
                        }
                     },
                     style: IconButton.styleFrom(
                       backgroundColor: TbpPalette.darkViolet, 
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                     icon: const Icon(Icons.arrow_forward),
                   ),
                ],
              ),
              const Divider(height: 48, color: Colors.black12),

              // Room List
              Expanded(
                child: BlocBuilder<CollectiveSessionBloc, CollectiveSessionState>(
                  builder: (context, state) {
                    if (state is CollectiveSessionLoading) {
                       return const Center(child: CircularProgressIndicator(color: TbpPalette.darkViolet));
                    }
                    if (state is CollectiveSessionLobby) {
                      if (state.isLoading) {
                         return const Center(child: CircularProgressIndicator(color: TbpPalette.darkViolet));
                      }
                      if (state.rooms.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.noActiveRooms,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: TbpPalette.darkViolet.withValues(alpha: 0.5), fontSize: 18),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                           context.read<CollectiveSessionBloc>().add(LoadRoomsRequested());
                        },
                        color: TbpPalette.darkViolet,
                        child: ListView.builder(
                          itemCount: state.rooms.length,
                          itemBuilder: (context, index) {
                            final room = state.rooms[index];
                            return _RoomCard(room: room);
                          },
                        ),
                      );
                    }
                    return Container(); // Should verify why we are here
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final TbpSession room;
  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          room.roomName ?? l10n.unnamedRoom,
          style: const TextStyle(fontWeight: FontWeight.bold, color: TbpPalette.darkViolet, fontSize: 18),
        ),
        subtitle: Text(
          '${l10n.roomCodePrefix(room.roomCode ?? "")} • ${l10n.startedPrefix(_formatTime(room.startTime))}',
          style: TextStyle(color: TbpPalette.darkViolet.withValues(alpha: 0.6)),
        ),
        trailing: ElevatedButton(
          onPressed: () {
             if (room.roomCode != null) {
               context.read<CollectiveSessionBloc>().add(JoinRoomRequested(room.roomCode!));
             }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TbpPalette.lilac,
            foregroundColor: TbpPalette.darkViolet,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(l10n.join),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
     return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }
}
