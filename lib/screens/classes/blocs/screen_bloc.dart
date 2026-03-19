import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'screen_event.dart';
part 'screen_state.dart';

class ScreenBloc extends Bloc<ScreenEvent, ScreenState> {
  ScreenBloc()
      : super(const ScreenState(
          availableClasses: [
            SkillClassModel(
              name: 'Seeker',
              subtitle: 'Discover the untold\nand the unseen',
              description:
                  'If solving puzzles and finding secret pathways is something that interests you, seeker is the class for you',
              perkLabel: 'Get hints when solving puzzles',
              icon: Icons.search_rounded,
            ),
            SkillClassModel(
              name: 'Warrior',
              subtitle: 'Fight with courage\nand strength',
              description:
                  'If you love combat and conquering enemies head-on, the Warrior class is built for your relentless spirit',
              perkLabel: 'Deal bonus damage in battles',
              icon: Icons.shield_outlined,
            ),
            SkillClassModel(
              name: 'Mage',
              subtitle: 'Command the arcane\nand the unknown',
              description:
                  'If wielding powerful spells and bending reality to your will excites you, the Mage class awaits you',
              perkLabel: 'Cast spells with greater power',
              icon: Icons.auto_fix_high_rounded,
            ),
          ],
        )) {
    on<ScreenPageChanged>(
      (event, emit) =>
          emit(state.copyWith(currentPageIndex: event.pageIndex)),
    );

    on<ScreenClassSelected>(
      (event, emit) => emit(state.copyWith(
        selectedClassName: event.className,
        status: ScreenStatus.selected,
      )),
    );

    on<ScreenSelectionConfirmed>(
      (event, emit) {
        if (state.selectedClassName != null) {
          // Emit confirmed so the listener fires exactly once
          emit(state.copyWith(status: ScreenStatus.confirmed));
          // Immediately reset so the listener never re-fires on rebuild
          emit(state.copyWith(
            status: ScreenStatus.initial,
            selectedClassName: state.selectedClassName,
          ));
        }
      },
    );
  }
}