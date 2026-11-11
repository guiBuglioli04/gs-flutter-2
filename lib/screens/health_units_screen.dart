import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/health_unit_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/state_views.dart';

/// Tela de Consumo de WebService REST (Requisito 4 - 2,0 pontos)
/// Implementa os 4 estados obrigatórios: Inicial, Carregamento, Sucesso e Erro
class HealthUnitsScreen extends StatefulWidget {
  const HealthUnitsScreen({super.key});

  @override
  State<HealthUnitsScreen> createState() => _HealthUnitsScreenState();
}

class _HealthUnitsScreenState extends State<HealthUnitsScreen> {
  final ApiService _apiService = ApiService();

  WebServiceState _state = WebServiceState.initial;
  List<HealthUnit> _units = [];
  String _errorMessage = '';
  bool _simulateError = false;
  String _searchFilter = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicia no estado inicial conforme requisito, ou pode carregar imediatamente
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Executa a requisição HTTP consumindo o endpoint REST (Requisito 4)
  Future<void> _fetchHealthUnits() async {
    setState(() {
      _state = WebServiceState.loading;
      _errorMessage = '';
    });

    try {
      final results = await _apiService.getHealthUnits(forceError: _simulateError);
      setState(() {
        _units = results;
        _state = WebServiceState.success;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _state = WebServiceState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rede de Unidades (API REST)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recarregar Dados',
            onPressed: _fetchHealthUnits,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de Controle para Teste de Avaliação (Permite testar Sucesso e Erro)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFFECEFF1),
            child: Row(
              children: [
                const Icon(Icons.bug_report_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Simular Erro de Rede (Banca / Avaliação):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Switch(
                  value: _simulateError,
                  activeThumbColor: AppColors.riskUrgent,
                  onChanged: (val) {
                    setState(() {
                      _simulateError = val;
                    });
                  },
                ),
              ],
            ),
          ),

          // Seletor dos 4 Estados (Requisito 4)
          Expanded(
            child: _buildBodyForCurrentState(),
          ),
        ],
      ),
    );
  }

  /// Constrói a interface com base no estado atual da requisição
  Widget _buildBodyForCurrentState() {
    switch (_state) {
      // Estado 1: Inicial (antes da requisição)
      case WebServiceState.initial:
        return InitialViewWidget(
          onFetch: _fetchHealthUnits,
        );

      // Estado 2: Carregamento (Loading com feedback)
      case WebServiceState.loading:
        return const LoadingViewWidget(
          message:
              'Consultando endpoint REST do WebService...\nConvertendo dados JSON em modelos Dart.',
        );

      // Estado 3: Erro (Mensagem amigável + botão Tentar Novamente)
      case WebServiceState.error:
        return ErrorViewWidget(
          errorMessage: _errorMessage,
          onRetry: _fetchHealthUnits,
        );

      // Estado 4: Sucesso (Exibição dos dados obtidos do WebService)
      case WebServiceState.success:
        return _buildSuccessContent();
    }
  }

  Widget _buildSuccessContent() {
    final filtered = _units.where((u) {
      if (_searchFilter.trim().isEmpty) return true;
      final q = _searchFilter.toLowerCase().trim();
      return u.name.toLowerCase().contains(q) ||
          u.type.toLowerCase().contains(q) ||
          u.city.toLowerCase().contains(q) ||
          u.address.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        // Barra de Pesquisa nas Unidades Carregadas
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Filtrar postos por nome, tipo ou localidade...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchFilter.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchFilter = '';
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (val) {
              setState(() {
                _searchFilter = val;
              });
            },
          ),
        ),

        // Resumo do WebService
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filtered.length} unidades conectadas via API REST',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.riskLow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'HTTP 200 OK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.riskLow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de Cards das Unidades
        Expanded(
          child: filtered.isEmpty
              ? const EmptyViewWidget(
                  title: 'Nenhuma unidade encontrada',
                  description: 'Ajuste os termos da busca acima.',
                  icon: Icons.search_off_rounded,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final unit = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                            color: Color(0xFFCFD8DC), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Foto / Ícone da Unidade com Image.network (Requisito 5)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    unit.imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 70,
                                      height: 70,
                                      color: AppColors.primaryLight,
                                      child: const Icon(
                                        Icons.local_hospital_rounded,
                                        color: AppColors.primary,
                                        size: 32,
                                      ),
                                    ),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 70,
                                        height: 70,
                                        color: const Color(0xFFECEFF1),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Informações Principais
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          unit.type,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        unit.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${unit.address} • ${unit.city}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),

                            // Detalhes de Atendimento e Teleorientação
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.near_me_outlined,
                                        size: 15, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${unit.distanceKm} km',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.people_outline,
                                        size: 15,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${unit.availableDoctors} médicos',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: unit.isOpen24h
                                        ? AppColors.riskLowBg
                                        : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    unit.isOpen24h
                                        ? 'Atendimento 24h'
                                        : 'Horário Comercial',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: unit.isOpen24h
                                          ? AppColors.riskLow
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
