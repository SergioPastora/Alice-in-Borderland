// lib/features/admin/presentation/pages/admin_page.dart

import 'package:alice_in_borderland/features/admin/presentation/cubit/admin_group_cubit.dart';
import 'package:alice_in_borderland/features/admin/presentation/cubit/admin_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../users/domain/entities/user_entity.dart';
import '../../../groups/domain/entities/group_entity.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bienvenido Game Master'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Usuarios'),
            Tab(text: 'Grupos'),
          ]),
        ),
        body: const TabBarView(children: [
          _UsersTab(),
          _GroupsTab(),
        ]),
      ),
    );
  }
}

/// === Pestaña de Usuarios ===
class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUserCubit, AdminUserState>(
      listener: (ctx, state) {
        if (state is AdminUserFailure) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (ctx, state) {
        if (state is AdminUserLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminUserFailure) {
          return Center(child: Text(state.message));
        }
        // AdminUserLoadSuccess
        final users = (state as AdminUserLoadSuccess).users;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (ctx, i) {
            final u = users[i];
            return ListTile(
              title: Text(u.nombre),
              subtitle: Text('Rol: ${u.rol}  Vidas: ${u.vidas}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editUserDialog(context, u),
              ),
            );
          },
        );
      },
    );
  }

  void _editUserDialog(BuildContext context, UserEntity user) {
    final nombreCtl = TextEditingController(text: user.nombre);
    int vidas = user.vidas;
    String rol = user.rol;
    DateTime visado = user.visadoHasta;

    final List<String> cartas = List.from(user.cartasGanadas);
    const suits = ['C', 'D', 'T', 'P'];
    const ranks = [
      'A',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K'
    ];
    String selectedSuit = suits.first;
    String selectedRank = ranks.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          title: const Text('Editar Usuario'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre / rol / vidas / visado...
                TextField(
                  controller: nombreCtl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: rol,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: ['usuario', 'admin']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => rol = v!,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: vidas.toString(),
                  decoration: const InputDecoration(labelText: 'Vidas'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => vidas = int.tryParse(v) ?? vidas,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Visado hasta:'),
                    TextButton(
                      child: Text('${visado.toLocal()}'.split(' ')[0]),
                      onPressed: () async {
                        final newDate = await showDatePicker(
                          context: ctx2,
                          initialDate: visado,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (newDate != null) visado = newDate;
                      },
                    ),
                  ],
                ),

                const Divider(height: 24),
                const Text('Cartas del usuario:'),
                const SizedBox(height: 8),

                // 1) Lista de chips con las cartas actuales
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: cartas.map((code) {
                    return Chip(
                      label: Text(code),
                      onDeleted: () {
                        setState(() => cartas.remove(code));
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                const Text('Añadir carta:'),
                const SizedBox(height: 8),

                // 2) Dropdowns palo + valor + botón añadir
                Row(
                  children: [
                    // Palo
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedSuit,
                        items: suits
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedSuit = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Valor
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedRank,
                        items: ranks
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedRank = v!),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        final code = '${selectedSuit}_$selectedRank';
                        if (!cartas.contains(code)) {
                          setState(() => cartas.add(code));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Construimos la entidad con la nueva lista de cartas
                final updated = UserEntity(
                  uid: user.uid,
                  nombre: nombreCtl.text,
                  email: user.email,
                  rol: rol,
                  vidas: vidas,
                  cartasGanadas: cartas,
                  grupoId: user.grupoId,
                  visadoHasta: visado,
                );
                context.read<AdminUserCubit>().updateUser(updated);
                Navigator.pop(ctx2);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// === Pestaña de Grupos ===
class _GroupsTab extends StatelessWidget {
  const _GroupsTab();

  @override
  Widget build(BuildContext context) {
    // Primero leemos todos los usuarios para mapear uid → nombre
    return BlocBuilder<AdminUserCubit, AdminUserState>(
      builder: (ctxU, userState) {
        if (userState is AdminUserLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userState is AdminUserFailure) {
          return Center(child: Text(userState.message));
        }
        final allUsers = (userState as AdminUserLoadSuccess).users;
        final nameMap = {for (var u in allUsers) u.uid: u.nombre};

        return BlocConsumer<AdminGroupCubit, AdminGroupState>(
          listener: (ctx, state) {
            if (state is AdminGroupFailure) {
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (ctxG, groupState) {
            if (groupState is AdminGroupLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (groupState is AdminGroupFailure) {
              return Center(child: Text(groupState.message));
            }
            final groups = (groupState as AdminGroupLoadSuccess).groups;

            return Column(
              children: [
                // Botón para añadir usuario a grupo
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Añadir usuario a grupo'),
                    onPressed: () => _addUserDialog(context, allUsers),
                  ),
                ),
                // Lista de grupos
                Expanded(
                  child: ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (ctx, i) {
                      final g = groups[i];
                      final membersNames = g.miembros
                          .map((uid) => nameMap[uid] ?? uid)
                          .join(', ');
                      return ListTile(
                        title: Text(g.nombre),
                        subtitle: Text('Miembros: $membersNames'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _editGroupDialog(context, g, allUsers),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addUserDialog(BuildContext context, List<UserEntity> allUsers) {
    String? selectedUser;
    String? selectedGroup;
    final List<GroupEntity> groups =
        context.read<AdminGroupCubit>().state is AdminGroupLoadSuccess
            ? (context.read<AdminGroupCubit>().state as AdminGroupLoadSuccess)
                .groups
            : <GroupEntity>[];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir usuario a grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Usuario'),
              items: allUsers
                  .map((u) => DropdownMenuItem(
                        value: u.uid,
                        child: Text(u.nombre),
                      ))
                  .toList(),
              onChanged: (v) => selectedUser = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Grupo'),
              items: groups
                  .map((g) => DropdownMenuItem(
                        value: g.id,
                        child: Text(g.nombre),
                      ))
                  .toList(),
              onChanged: (v) => selectedGroup = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedUser != null && selectedGroup != null) {
                context
                    .read<AdminGroupCubit>()
                    .moveUser(selectedUser!, selectedGroup!);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _editGroupDialog(
    BuildContext context,
    GroupEntity group,
    List<UserEntity> allUsers,
  ) {
    final nombreCtl = TextEditingController(text: group.nombre);
    final cubit = context.read<AdminGroupCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Grupo'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nombreCtl,
                decoration: const InputDecoration(labelText: 'Nombre de grupo'),
              ),
              const SizedBox(height: 12),
              const Text('Miembros:'),
              ...group.miembros.map((uid) {
                // mostramos nombre y permitimos cambiar de grupo
                return ListTile(
                  title: Text(
                    allUsers.firstWhere((u) => u.uid == uid).nombre,
                  ),
                  trailing: DropdownButton<String>(
                    value: group.id,
                    items: groupsDropdown(context),
                    onChanged: (sel) {
                      if (sel != null && sel != group.id) {
                        cubit.moveUser(uid, sel);
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = GroupEntity(
                id: group.id,
                nombre: nombreCtl.text,
                miembros: group.miembros,
                cartasColectivas: group.cartasColectivas,
              );
              cubit.updateGroup(updated);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Helper para el dropdown de grupos (0,1,…)
  List<DropdownMenuItem<String>> groupsDropdown(BuildContext context) {
    final state = context.read<AdminGroupCubit>().state;
    final groups = state is AdminGroupLoadSuccess ? state.groups : [];
    return groups
        .map(
            (g) => DropdownMenuItem<String>(value: g.id, child: Text(g.nombre)))
        .toList();
  }
}
