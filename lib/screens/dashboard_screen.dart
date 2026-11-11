import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/triage_model.dart';
import '../services/storage_service.dart';
import '../services/triage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/metric_card.dart';
import '../widgets/triage_card.dart';
import 'health_units_screen.dart';
import 'new_triage_screen.dart';
import 'onboarding_screen.dart';
import 'triage_detail_screen.dart';
import 'triage_list_screen.dart';

/// Tela Principal 1: Dashboard de Impacto & Triagens Comunitárias (Requisito 3)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TriageService _triageService = TriageService.instance;
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _loadOfflineSetting();
  }

  Future<void> _loadOfflineSetting() async {
    final offline = await StorageService.isOfflineMode();
    setState(() {
      _isOfflineMode = offline;
    });
  }

  void _refresh() {
    setState(() {});
  }

  void _navigateToNewTriage() async {
    final result = await Navigator.of(context).push<Triage>(
      MaterialPageRoute(builder: (_) => const NewTriageScreen()),
    );
    if (result != null) {
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ficha registrada com sucesso! Protocolo: ${result.protocol}',
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Ver Detalhes',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TriageDetailScreen(triage: result),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  void _navigateToQueue({RiskLevel? filter}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TriageListScreen(initialRiskFilter: filter),
      ),
    );
    _refresh();
  }

  void _navigateToHealthUnits() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HealthUnitsScreen()),
    );
  }

  void _openResetDialog() async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configurações do Avaliador'),
        content: const Text(
          'Deseja redefinir a preferência do Onboarding para testar a Tela de Introdução novamente na próxima inicialização?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Abrir Onboarding'),
          ),
        ],
      ),
    );

    if (shouldOpen == true) {
      await StorageService.resetOnboardingPreference();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _triageService.countUrgent;
    final moderate = _triageService.countModerate;
    final low = _triageService.countLow;
    final avoidedTrips = _triageService.countAvoidedTrips;
    final pendingCount = _triageService.countPending;

    // Pega as triagens pendentes mais prioritárias para exibir no dashboard
    final pendingTriages = _triageService
        .filterTriages(statusFilter: TriageStatus.pendente)
        .take(3)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_saudeperto.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.favorite),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SaúdePerto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Painel de Triagem Comunitária',
                  style: TextStyle(fontSize: 11, color: Color(0xFFB2DFDB)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Configurações / Testar Onboarding',
            onPressed: _openResetDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar Painel',
            onPressed: _refresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de Status da Conexão / Modo Offline-First (RNF01)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _isOfflineMode
                  ? const Color(0xFFFFF3E0)
                  : const Color(0xFFE8F5E9),
              child: Row(
                children: [
                  Icon(
                    _isOfflineMode
                        ? Icons.cloud_queue_rounded
                        : Icons.wifi_tethering_rounded,
                    size: 18,
                    color: _isOfflineMode
                        ? Colors.orange[800]
                        : AppColors.riskLow,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isOfflineMode
                          ? 'Modo Offline Ativo: dados salvos localmente e sincronizados após reconexão.'
                          : 'Conectado à Rede de Teleorientação Comunitária.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isOfflineMode
                            ? Colors.orange[900]
                            : AppColors.riskLow,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final newVal = !_isOfflineMode;
                      await StorageService.setOfflineMode(newVal);
                      setState(() {
                        _isOfflineMode = newVal;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _isOfflineMode ? 'Ativar Online' : 'Simular Offline',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            // Card Principal de Boas-Vindas & ODS (CitizenTech)
            Card(
              margin: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Impacto Social & Saúde Comunitária',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            _odsBadge('ODS 3', AppColors.ods3),
                            const SizedBox(width: 4),
                            _odsBadge('ODS 10', AppColors.ods10),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Monitoramento preventivo em territórios periféricos e isolados, gerando protocolos clínicos inteligentes e priorizando casos críticos.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE0F2F1),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _navigateToNewTriage,
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            label: const Text('Nova Triagem'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryDark,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToQueue(),
                            icon: const Icon(Icons.format_list_bulleted,
                                size: 20, color: Colors.white),
                            label: Text(
                              'Fila ($pendingCount)',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Seção de Métricas de Triagem (GridView de Cards)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Classificação de Risco & Atendimentos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToQueue(),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Urgência',
                      value: '$urgent',
                      subtitle: 'Atendimento imediato',
                      icon: Icons.error_rounded,
                      color: AppColors.riskUrgent,
                      onTap: () => _navigateToQueue(filter: RiskLevel.urgente),
                    ),
                  ),
                  Expanded(
                    child: MetricCard(
                      title: 'Moderado',
                      value: '$moderate',
                      subtitle: 'Atenção no mesmo dia',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.riskModerate,
                      onTap: () => _navigateToQueue(filter: RiskLevel.moderado),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Baixo Risco',
                      value: '$low',
                      subtitle: 'Acompanhamento',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.riskLow,
                      onTap: () => _navigateToQueue(filter: RiskLevel.baixo),
                    ),
                  ),
                  Expanded(
                    child: MetricCard(
                      title: 'Viagens Evitadas',
                      value: '$avoidedTrips',
                      subtitle: 'Deslocamentos poupados',
                      icon: Icons.directions_boat_rounded,
                      color: AppColors.ods3,
                      onTap: () => _navigateToQueue(),
                    ),
                  ),
                ],
              ),
            ),

            // Botão Direto para Consumo de WebService REST (Requisito 4)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFB2DFDB), width: 1.2),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cell_tower_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text(
                  'Rede de Telepostos & UBS (API REST)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: const Text(
                  'Consumo de WebService com estados: Inicial, Carregamento, Sucesso e Erro.',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: _navigateToHealthUnits,
              ),
            ),

            // Triagens Críticas Recentes
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fila Prioritária de Avaliação',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (pendingTriages.isNotEmpty)
                    Text(
                      '${pendingTriages.length} prioritários',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),

            if (pendingTriages.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 40, color: AppColors.riskLow),
                      const SizedBox(height: 8),
                      const Text(
                        'Nenhuma triagem pendente no momento!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _navigateToNewTriage,
                        icon: const Icon(Icons.add),
                        label: const Text('Cadastrar Nova Ficha'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...pendingTriages.map(
                (triage) => TriageCard(
                  triage: triage,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TriageDetailScreen(triage: triage),
                      ),
                    );
                    _refresh();
                  },
                  onToggleFavorite: () async {
                    await _triageService.toggleFavorite(triage.protocol);
                    _refresh();
                  },
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        onTap: (index) {
          if (index == 1) {
            _navigateToQueue();
          } else if (index == 2) {
            _navigateToNewTriage();
          } else if (index == 3) {
            _navigateToHealthUnits();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted_rounded),
            label: 'Fila de Risco',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Nova Triagem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment_rounded),
            label: 'Unidades API',
          ),
        ],
      ),
    );
  }

  Widget _odsBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
