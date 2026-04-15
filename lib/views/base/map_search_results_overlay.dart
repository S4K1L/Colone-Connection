import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/home_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/colony_search_result_card.dart';
import 'package:flutter_extension/views/base/customer_search_result_card.dart';
import 'package:flutter_extension/views/base/map_search_header_bar.dart';
import 'package:flutter_extension/views/base/search_filter_chips_row.dart';
import 'package:flutter_extension/views/base/search_no_results_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full-screen map search: gradient header + white rounded body, chips, list or empty state.
class MapSearchResultsOverlay extends StatelessWidget {
  const MapSearchResultsOverlay({
    super.key,
    required this.home,
  });

  final HomeController home;

  @override
  Widget build(BuildContext context) {
    final double topR = 26.r;
    final List<SearchFilterChipData> chips = home.buildSearchFilterChips();
    final bool hasAny = home.hasSearchMatches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Color(0xFF408E1A),
                Color(0xFF17B85F),
              ],
            ),
          ),
          child: MapSearchHeaderBar(
            controller: home.searchController,
            onBack: home.closeSearch,
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(topR),
                topRight: Radius.circular(topR),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 16.h),
                SearchFilterChipsRow(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  chips: chips,
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: hasAny
                      ? _SearchResultsList(home: home)
                      : SearchNoResultsState(
                          query: home.searchQueryDisplay,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.home});

  final HomeController home;

  @override
  Widget build(BuildContext context) {
    final colonies = home.visibleColonyResults;
    final customers = home.visibleCustomerResults;
    final bool showColonies = colonies.isNotEmpty;
    final bool showCustomers = customers.isNotEmpty;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      children: <Widget>[
        if (showColonies) ...<Widget>[
          AppText.smd(
            'Colony (${colonies.length})',
            fontSize: 15,
            color: AppColors.grey500,
            useResponsiveSize: true,
          ),
          SizedBox(height: 12.h),
          for (int i = 0; i < colonies.length; i++) ...<Widget>[
            ColonySearchResultCard(colony: colonies[i]),
            if (i < colonies.length - 1 || showCustomers) SizedBox(height: 12.h),
          ],
        ],
        if (showCustomers) ...<Widget>[
          if (showColonies) SizedBox(height: 8.h),
          AppText.smd(
            'Customers (${customers.length})',
            fontSize: 15,
            color: AppColors.grey500,
            useResponsiveSize: true,
          ),
          SizedBox(height: 12.h),
          for (int i = 0; i < customers.length; i++) ...<Widget>[
            CustomerSearchResultCard(customer: customers[i]),
            if (i < customers.length - 1) SizedBox(height: 12.h),
          ],
        ],
      ],
    );
  }
}
