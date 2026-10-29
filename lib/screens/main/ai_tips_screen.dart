import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/app_image_box.dart';
import '../../widgets/gradient_button.dart';
import 'ai_chat_screen.dart';
import 'profile_screen.dart';

// data model for personalised ai recommendation cards
class AiPlace {
  const AiPlace({
    required this.imagePath,
    required this.label,
    required this.labelColor,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.walkTime,
    required this.matchPercent,
  });

  final String imagePath;
  final String label;
  final Color labelColor;
  final String title;
  final String subtitle;
  final List<String> tags;
  final String walkTime;
  final String matchPercent;
}

// ai tips screen for tp go
class AiTipsScreen extends ConsumerStatefulWidget {
  const AiTipsScreen({super.key});

  @override
  ConsumerState<AiTipsScreen> createState() {
    return _AiTipsScreenState();
  }
}

class _AiTipsScreenState
    extends ConsumerState<AiTipsScreen> {
  final TextEditingController _questionController =
      TextEditingController();

  final List<AiPlace> _personalisedPlaces = const [
    AiPlace(
      imagePath: 'images/library.png',
      label: 'Best for study',
      labelColor: Color(0xFF7C35FF),
      title: 'Library Level 7',
      subtitle: 'Learning Hub',
      tags: ['Quiet', 'High Seats'],
      walkTime: '3 min walk',
      matchPercent: '95% match',
    ),
    AiPlace(
      imagePath: 'images/breadboard.png',
      label: 'Good for you',
      labelColor: Color(0xFF10A84B),
      title: 'Breadboard',
      subtitle: 'Student Run Café',
      tags: ['Vegetarian', 'Low Crowd'],
      walkTime: '2 min walk',
      matchPercent: '92% match',
    ),
    AiPlace(
      imagePath: 'images/surau.png',
      label: 'Peaceful Space',
      labelColor: Color(0xFF2667FF),
      title: 'Surau An-Nur',
      subtitle: 'Block 22, Level 3',
      tags: ['Prayer Space', 'Peaceful'],
      walkTime: '4 min walk',
      matchPercent: '90% match',
    ),
  ];

  bool get _isDark {
    return Theme.of(context).brightness ==
        Brightness.dark;
  }

  Color get _pageBackground {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color get _surfaceColor {
    return Theme.of(context).colorScheme.surface;
  }

  // ignore: unused_element
  Color get _surfaceSecondary {
    return Theme.of(context).colorScheme.surfaceContainer;
  }

  Color get _primaryText {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color get _secondaryText {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color get _borderColor {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  Color get _shadowColor {
    return _isDark
        ? Colors.black.withValues(alpha: 0.22)
        : Colors.black.withValues(alpha: 0.055);
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  // opens the ai chat with the typed question
  void _askAi() {
    final question =
        _questionController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please type what you need help with.',
          ),
          backgroundColor:
              Color(0xFF2637FF),
        ),
      );

      return;
    }

    Navigator.of(context).pushNamed(
      AiChatScreen.routeName,
      arguments: question,
    );
  }

  void _usePrompt(String prompt) {
    setState(() {
      _questionController.text = prompt;
    });

    _askAi();
  }

  Widget _buildHeader(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        18,
        22,
        10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Tips',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight:
                        FontWeight.w900,
                    color: _primaryText,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Smart recommendations, just for you',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    fontWeight:
                        FontWeight.w500,
                    color:
                        _secondaryText,
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            borderRadius:
                BorderRadius.circular(
              42,
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(
                ProfileScreen.routeName,
              );
            },
            child: Container(
              height: 78,
              width: 78,
              padding:
                  const EdgeInsets.all(
                4,
              ),
              decoration: BoxDecoration(
                color: _surfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _shadowColor,
                    blurRadius: 16,
                    offset:
                        const Offset(
                      0,
                      6,
                    ),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'images/profile.png',
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Icon(
                      Icons.person,
                      size: 40,
                      color:
                          Color(
                        0xFF2637FF,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiWelcomeCard(
    String displayName,
  ) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        22,
        18,
        22,
        22,
      ),
      height: 138,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: _isDark
              ? const [
                  Color(0xFF232C52),
                  Color(0xFF1D2742),
                ]
              : const [
                  Color(0xFFE2E0FF),
                  Color(0xFFF2F5FF),
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 22,
            top: 25,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi $displayName! 👋',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w900,
                    color: _primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'I’m your AI campus assistant.\n'
                  'How can I help you today?',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    color:
                        _secondaryText,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 6,
            bottom: -6,
            child: AppImageBox(
              imagePath:
                  'images/robot.png',
              height: 135,
              width: 145,
              fit: BoxFit.contain,
              fallback: const Icon(
                Icons
                    .smart_toy_outlined,
                size: 75,
                color:
                    Color(0xFF2637FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      padding:
          const EdgeInsets.fromLTRB(
        18,
        5,
        8,
        5,
      ),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius:
            BorderRadius.circular(28),
        border: _isDark
            ? Border.all(
                color: _borderColor,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 16,
            offset:
                const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 27,
            color: _secondaryText,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller:
                  _questionController,
              keyboardType:
                  TextInputType.text,
              textInputAction:
                  TextInputAction.search,
              style: TextStyle(
                color: _primaryText,
                fontSize: 15.5,
                fontWeight:
                    FontWeight.w600,
              ),
              onSubmitted: (value) {
                _askAi();
              },
              decoration:
                  InputDecoration(
                hintText:
                    'Ask Me Anything!',
                hintStyle: TextStyle(
                  color: _isDark
                      ? const Color(
                          0xFF8F99B3,
                        )
                      : const Color(
                          0xFF8D92AA,
                        ),
                  fontSize: 15.5,
                  fontWeight:
                      FontWeight.w500,
                ),

                // stops the app theme from
                // putting a dark box inside this field
                filled: false,
                fillColor:
                    Colors.transparent,

                border:
                    InputBorder.none,
                enabledBorder:
                    InputBorder.none,
                focusedBorder:
                    InputBorder.none,
                contentPadding:
                    EdgeInsets.zero,
              ),
            ),
          ),

          InkWell(
            borderRadius:
                BorderRadius.circular(
              24,
            ),
            onTap: _askAi,
            child: Container(
              height: 52,
              width: 52,
              decoration:
                  const BoxDecoration(
                shape:
                    BoxShape.circle,
                gradient:
                    LinearGradient(
                  colors: [
                    Color(
                      0xFF1835FF,
                    ),
                    Color(
                      0xFFA736D8,
                    ),
                  ],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 27,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required String text,
  }) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(20),
      onTap: () {
        _usePrompt(text);
      },
      child: Container(
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius:
              BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: _borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration:
                  BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 27,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.25,
                  color: _primaryText,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTryAskingSection() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        28,
        22,
        0,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Try asking',
            style: TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.w900,
              color: _primaryText,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child:
                    _buildPromptCard(
                  icon: Icons
                      .menu_book_rounded,
                  backgroundColor:
                      const Color(
                    0xFFF0EAFF,
                  ),
                  iconColor:
                      const Color(
                    0xFF6B3DFF,
                  ),
                  text:
                      'Best quiet places\n'
                      'to study',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child:
                    _buildPromptCard(
                  icon:
                      Icons.local_cafe,
                  backgroundColor:
                      const Color(
                    0xFFE9F8EF,
                  ),
                  iconColor:
                      const Color(
                    0xFF14943D,
                  ),
                  text:
                      'Where can I get good\n'
                      'food nearby?',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child:
                    _buildPromptCard(
                  icon: Icons.groups,
                  backgroundColor:
                      const Color(
                    0xFFFFEDE7,
                  ),
                  iconColor:
                      const Color(
                    0xFFFF5B18,
                  ),
                  text:
                      'Places good for\n'
                      'group work',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child:
                    _buildPromptCard(
                  icon: Icons
                      .calendar_month,
                  backgroundColor:
                      const Color(
                    0xFFEAF2FF,
                  ),
                  iconColor:
                      const Color(
                    0xFF2C7BE5,
                  ),
                  text:
                      'What’s happening\n'
                      'on campus?',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _tagBackgroundColor(
    String tag,
  ) {
    if (_isDark) {
      if (tag.contains(
        'Vegetarian',
      )) {
        return const Color(
          0xFF25362B,
        );
      }

      if (tag.contains('Prayer') ||
          tag.contains('Quiet')) {
        return const Color(
          0xFF30274A,
        );
      }

      return const Color(
        0xFF24334B,
      );
    }

    if (tag.contains(
      'Vegetarian',
    )) {
      return const Color(
        0xFFEAF6DD,
      );
    } else if (tag.contains(
          'Prayer',
        ) ||
        tag.contains('Quiet')) {
      return const Color(
        0xFFF0E8FF,
      );
    } else if (tag.contains(
          'Low',
        ) ||
        tag.contains(
          'Peaceful',
        )) {
      return const Color(
        0xFFEAF2FF,
      );
    }

    return const Color(
      0xFFEAF2FF,
    );
  }

  Color _tagTextColor(
    String tag,
  ) {
    if (_isDark) {
      if (tag.contains(
        'Vegetarian',
      )) {
        return const Color(
          0xFF95D67B,
        );
      }

      if (tag.contains('Prayer') ||
          tag.contains('Quiet')) {
        return const Color(
          0xFFB99AFF,
        );
      }

      return const Color(
        0xFF8DBCEB,
      );
    }

    if (tag.contains(
      'Vegetarian',
    )) {
      return const Color(
        0xFF4A7B26,
      );
    } else if (tag.contains(
          'Prayer',
        ) ||
        tag.contains('Quiet')) {
      return const Color(
        0xFF6B3DFF,
      );
    }

    return const Color(
      0xFF2C6FB8,
    );
  }

  Widget _buildSmallTag(
    String tag,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
            _tagBackgroundColor(tag),
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight:
              FontWeight.w800,
          color:
              _tagTextColor(tag),
        ),
      ),
    );
  }

  Widget _buildPersonalisedCard(
    AiPlace place,
  ) {
    return Container(
      width: 180,
      margin:
          const EdgeInsets.only(
        right: 14,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius:
            BorderRadius.circular(18),
        border: _isDark
            ? Border.all(
                color: _borderColor,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 16,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AppImageBox(
                imagePath:
                    place.imagePath,
                height: 118,
                width: 180,
                fit: BoxFit.cover,
                borderRadius:
                    const BorderRadius
                        .only(
                  topLeft:
                      Radius.circular(
                    18,
                  ),
                  topRight:
                      Radius.circular(
                    18,
                  ),
                ),
                fallback: const Icon(
                  Icons.place_outlined,
                  size: 42,
                  color:
                      Color(
                    0xFF2637FF,
                  ),
                ),
              ),

              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        place.labelColor,
                    borderRadius:
                        BorderRadius
                            .circular(
                      16,
                    ),
                  ),
                  child: Text(
                    place.label,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 10.5,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding:
                const EdgeInsets
                    .fromLTRB(
              14,
              12,
              14,
              12,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  place.title,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight
                            .w900,
                    color:
                        _primaryText,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  place.subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color:
                        _secondaryText,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),

                const SizedBox(
                  height: 11,
                ),

                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: place.tags
                      .map(
                        (tag) =>
                            _buildSmallTag(
                          tag,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(
                  height: 12,
                ),

                Row(
                  children: [
                    Icon(
                      Icons
                          .directions_walk,
                      size: 15,
                      color:
                          _secondaryText,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      place.walkTime,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            _primaryText,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color:
                          Color(
                        0xFFFFC107,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      place.matchPercent,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            FontWeight
                                .w900,
                        color:
                            _primaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalisedSection() {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets
                  .fromLTRB(
            22,
            30,
            22,
            14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Personalised for you',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight
                            .w900,
                    color:
                        _primaryText,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  ref
                      .read(
                        selectedTabProvider
                            .notifier,
                      )
                      .setTab(
                        TabIndex.explore,
                      );
                },
                child: const Text(
                  'View all  →',
                  style: TextStyle(
                    color:
                        Color(
                      0xFF8D6BFF,
                    ),
                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 352,
          child: ListView.builder(
            padding:
                const EdgeInsets.only(
              left: 22,
              bottom: 8,
            ),
            scrollDirection:
                Axis.horizontal,
            itemCount:
                _personalisedPlaces
                    .length,
            itemBuilder: (
              context,
              index,
            ) {
              return _buildPersonalisedCard(
                _personalisedPlaces[
                    index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionRow({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String smallText,
    required String boldText,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        14,
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration:
                BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color:
                      _secondaryText,
                  fontWeight:
                      FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text:
                        '$smallText\n',
                  ),
                  TextSpan(
                    text: boldText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .w900,
                      color:
                          _primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration:
                  BoxDecoration(
                color: _isDark
                    ? const Color(
                        0xFF30274A,
                      )
                    : const Color(
                        0xFFF0EAFF,
                      ),
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
              ),
              child: Text(
                'buttonText',
                style: TextStyle(
                  color:
                      Color(
                    0xFF8D6BFF,
                  ),
                  fontWeight:
                      FontWeight
                          .w900,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          Icon(
            Icons.chevron_right,
            color:
                _secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        28,
        22,
        0,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'AI suggestions for you',
            style: TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.w900,
              color: _primaryText,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius:
                  BorderRadius.circular(
                22,
              ),
              border: _isDark
                  ? Border.all(
                      color:
                          _borderColor,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: _shadowColor,
                  blurRadius: 16,
                  offset:
                      const Offset(
                    0,
                    7,
                  ),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSuggestionRow(
                  icon: Icons.bolt,
                  iconBackground:
                      const Color(
                    0xFFF0EAFF,
                  ),
                  iconColor:
                      const Color(
                    0xFF6B3DFF,
                  ),
                  smallText:
                      'It looks like you study a lot in the evenings.',
                  boldText:
                      'Want cozy cafes with power outlets?',
                  buttonText:
                      'View places',
                  onTap: () {
                    ref
                        .read(
                          selectedTabProvider
                              .notifier,
                        )
                        .setTab(
                          TabIndex
                              .explore,
                        );
                  },
                ),

                Divider(
                  height: 0,
                  color: _borderColor,
                ),

                _buildSuggestionRow(
                  icon:
                      Icons.explore,
                  iconBackground:
                      const Color(
                    0xFFE8F8EA,
                  ),
                  iconColor:
                      const Color(
                    0xFF14943D,
                  ),
                  smallText:
                      'You haven’t visited any new places this month.',
                  boldText:
                      'Explore something new this week!',
                  buttonText:
                      'Explore now',
                  onTap: () {
                    ref
                        .read(
                          selectedTabProvider
                              .notifier,
                        )
                        .setTab(
                          TabIndex
                              .explore,
                        );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpBanner() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        22,
        26,
        22,
        28,
      ),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(
                0xFF202B45,
              )
            : const Color(
                0xFFF0F1FF,
              ),
        borderRadius:
            BorderRadius.circular(22),
        border: _isDark
            ? Border.all(
                color: _borderColor,
              )
            : null,
      ),
      child: Row(
        children: [
          const AppImageBox(
            imagePath:
                'images/robot.png',
            height: 74,
            width: 74,
            fit: BoxFit.contain,
            fallback: Icon(
              Icons
                  .smart_toy_outlined,
              color:
                  Color(0xFF2637FF),
              size: 42,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Still need help?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight
                            .w900,
                    color:
                        _primaryText,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Ask me anything, I’m here to help.',
                  style: TextStyle(
                    color:
                        _secondaryText,
                    fontSize: 13,
                    fontWeight:
                        FontWeight
                            .w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 145,
            child: GradientButton(
              text:
                  'Chat with AI  ✨',
              height: 48,
              fontSize: 13.5,
              onPressed: () {
                _questionController
                        .text =
                    'I need help choosing a place';

                _askAi();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final user =
        ref.watch(
      firebaseServiceProvider,
    ).currentUser;

    String displayName =
        user?.displayName ??
            'there';

    if (displayName.contains(' ')) {
      displayName =
          displayName
              .split(' ')
              .first;
    }

    return ColoredBox(
      color: _pageBackground,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context),
            _buildAiWelcomeCard(
              displayName,
            ),
            _buildSearchBar(),
            _buildTryAskingSection(),
            _buildPersonalisedSection(),
            _buildSuggestionsSection(),
            _buildHelpBanner(),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}