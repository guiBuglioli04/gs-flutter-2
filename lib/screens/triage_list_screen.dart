import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/triage_model.dart';
import '../services/triage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/state_views.dart';
import '../widgets/triage_card.dart';
import 'new_triage_screen.dart';
import 'triage_detail_screen.dart';

/// Tela Principal 2: Fila Prioritária de Triagem Clínica (RF04, Requisito 3 e 6)
class TriageListScreen extends StatefulWidget {
  final RiskLevel? initialRiskFilter;

  const TriageListScreen({
    super.key,
    this.initialRiskFilter,
  });

  @override
  State<TriageListScreen> createState() => _TriageListScreenState();
}

class _TriageListScreenState extends State<TriageListScreen> {
  final TriageService _triageService = TriageService.instance;
  final TextEditingController _searchController = TextEditingController();

  RiskLevel? _selectedRisk;
  bool _onlyFavorites = false;
  TriageStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedRisk = widget.initialRiskFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedRisk = null;
      _onlyFavorites = false;
      _selectedStatus = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _triageService.filterTriages(
      riskFilter: _selectedRisk,
      query: _searchQuery,
      onlyFavorites: _onlyFavorites,
      statusFilter: _selectedStatus,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fila de Triagem Preventiva'),
        actions: [
          IconButton(
            icon: Icon(
              _onlyFavorites ? Icons.star : Icons.star_border,
              color: _onlyFavorites ? Colors.amber : Colors.white,
            ),
            tooltip: _onlyFavorites
                ? 'Exibir todas as triagens'
                : 'Filtrar apenas favoritos',
            onPressed: () {
              setState(() {
                _onlyFavorites = !_onlyFavorites;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar Fila',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Pesquisa em Tempo Real
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome, CPF ou protocolo...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Chips de Filtro por Risco Clínico e Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedRisk == null &&
                        !_onlyFavorites &&
                        _selectedStatus == null,
                    onSelected: (_) => _clearFilters(),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.error, size: 14, color: AppColors.riskUrgent),
                        SizedBox(width: 4),
                        Text('Urgente'),
                      ],
                    ),
                    selected: _selectedRisk == RiskLevel.urgente,
                    selectedColor: AppColors.riskUrgentBg,
                    onSelected: (selected) {
                      setState(() {
                        _selectedRisk = selected ? RiskLevel.urgente : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.warning,
                            size: 14, color: AppColors.riskModerate),
                        SizedBox(width: 4),
                        Text('Moderado'),
                      ],
                    ),
                    selected: _selectedRisk == RiskLevel.moderado,
                    selectedColor: AppColors.riskModerateBg,
                    onSelected: (selected) {
                      setState(() {
                        _selectedRisk = selected ? RiskLevel.moderado : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle,
                            size: 14, color: AppColors.riskLow),
                        SizedBox(width: 4),
                        Text('Baixo'),
                      ],
                    ),
                    selected: _selectedRisk == RiskLevel.baixo,
                    selectedColor: AppColors.riskLowBg,
                    onSelected: (selected) {
                      setState(() {
                        _selectedRisk = selected ? RiskLevel.baixo : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Pendentes'),
                    selected: _selectedStatus == TriageStatus.pendente,
                    selectedColor: AppColors.statusPendingBg,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus =
                            selected ? TriageStatus.pendente : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Orientação Emitida'),
                    selected: _selectedStatus == TriageStatus.orientacaoEmitida,
                    selectedColor: AppColors.statusCompletedBg,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus =
                            selected ? TriageStatus.orientacaoEmitida : null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Contador de resultados e ordenação
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredList.length} triagem(ns) encontrada(s)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.sort_rounded,
                        size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      'Prioridade Clínica',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de Triagens ou Empty State
          Expanded(
            child: filteredList.isEmpty
                ? EmptyViewWidget(
                    title: 'Nenhuma triagem encontrada',
                    description:
                        'Não há fichas correspondentes aos filtros selecionados. Tente ajustar os termos de busca.',
                    icon: Icons.search_off_rounded,
                    action: OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Limpar Filtros'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final triage = filteredList[index];
                      return TriageCard(
                        triage: triage,
                        onTap: () async {
                          // Requisito 3 & 6: Navegação de um item da lista para a tela de detalhes com passagem de parâmetros
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TriageDetailScreen(triage: triage),
                            ),
                          );
                          setState(() {});
                        },
                        onToggleFavorite: () async {
                          // Interação funcional com feedback perceptível
                          await _triageService.toggleFavorite(triage.protocol);
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova Triagem'),
        onPressed: () async {
          final newTriage = await Navigator.of(context).push<Triage>(
            MaterialPageRoute(builder: (_) => const NewTriageScreen()),
          );
          if (newTriage != null) {
            setState(() {});
          }
        },
      ),
    );
  }
}
