import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';

class OnboardingPageData {
  final String imagePath;
  final IconData fallbackIcon;
  final String title;
  final String description;
  final String tag;
  final Color tagColor;

  const OnboardingPageData({
    required this.imagePath,
    required this.fallbackIcon,
    required this.title,
    required this.description,
    required this.tag,
    required this.tagColor,
  });
}

/// Tela de Introdução / Onboarding (Requisito 2 - 1,5 ponto)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_1.png',
      fallbackIcon: Icons.volunteer_activism_rounded,
      tag: 'Cidadania & Equidade (ODS 3 e 10)',
      tagColor: AppColors.ods3,
      title: 'Saúde Perto de Quem Mais Precisa',
      description:
          'Moradores de regiões periféricas e comunidades ribeirinhas ou rurais enfrentam barreiras geográficas severas. O SaúdePerto leva a triagem preventiva até o território, com fichas padronizadas operando mesmo em baixa conectividade.',
    ),
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_2.png',
      fallbackIcon: Icons.speed_rounded,
      tag: 'Motor Clínico Inteligente',
      tagColor: AppColors.riskModerate,
      title: 'Classificação Automática de Risco',
      description:
          'Ao registar os sinais vitais (pressão arterial, glicemia e temperatura) e sintomas, o algoritmo categoriza imediatamente o risco em Baixo (Verde), Moderado (Amarelo) ou Urgente (Vermelho), gerando protocolo único e prioridade na fila.',
    ),
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_3.png',
      fallbackIcon: Icons.medical_services_rounded,
      tag: 'Teleorientação Remota',
      tagColor: AppColors.primary,
      title: 'Fila Prioritária e Redução de Viagens',
      description:
          'Médicos e enfermeiros acessam a fila priorizada para emitir condutas imediatas. Casos leves são orientados no próprio domicílio, evitando horas de viagem de barco ou ônibus e desafogando os hospitais centrais.',
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    // Requisito 2: Ao finalizar a introdução, salvar a preferência do usuário utilizando SharedPreferences, respeitando a opção selecionada
    if (_dontShowAgain) {
      await StorageService.setDontShowOnboarding(true);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text(
              'Pular',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Carrossel de páginas (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tag / Selo do Tema
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: page.tagColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            page.tag,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: page.tagColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Imagem da Página (Image.asset com fallback)
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              page.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.primaryLight,
                                  child: Icon(
                                    page.fallbackIcon,
                                    size: 90,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Título
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Descrição
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicador de Bolinhas (Page Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : const Color(0xFFCFD8DC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Opção "Não mostrar novamente" (Requisito 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _dontShowAgain = !_dontShowAgain;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _dontShowAgain,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _dontShowAgain = val ?? false;
                          });
                        },
                      ),
                      const Text(
                        'Não mostrar novamente ao iniciar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Botões de Avançar e Voltar (Requisito 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  // Botão Voltar (desabilitado na primeira página)
                  if (_currentPage > 0)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _onPrevious,
                        child: const Text('Voltar'),
                      ),
                    )
                  else
                    const SizedBox(width: 0),

                  if (_currentPage > 0) const SizedBox(width: 12),

                  // Botão Próximo ou Começar
                  Expanded(
                    flex: _currentPage > 0 ? 2 : 1,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isLastPage ? 'Começar' : 'Avançar'),
                          const SizedBox(width: 6),
                          Icon(
                            isLastPage
                                ? Icons.arrow_forward_rounded
                                : Icons.chevron_right_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
