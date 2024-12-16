import 'dart:async';

import 'state.dart';
import 'repository.dart';

abstract class RestaurantController {
  Future<void> loadMenu();
  Future<void> loadOrders();
  Future<void> addOrder(Order order);
  Stream<RestaurantState> get stream;
  RestaurantState get state;
}

class RestaurantControllerImpl implements RestaurantController {
  final StreamController<RestaurantState> _controller =
      StreamController<RestaurantState>.broadcast();

  RestaurantState _state = const RestaurantState(isLoading: false);

  final RestaurantRepository _repository;

  RestaurantControllerImpl({
    required RestaurantRepository repository,
  }) : _repository = repository;

  @override
  Stream<RestaurantState> get stream => _controller.stream;

  @override
  RestaurantState get state => _state;

  void emit(RestaurantState newState) {
    _state = newState;
    _controller.add(newState);
  }

  @override
  Future<void> loadMenu() async {
    if (state.isLoading) {
      return;
    }

    emit(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      final menuResult = await _repository.loadMenu();

      emit(_state.copyWith(isLoading: false, menuItems: menuResult));
    } catch (error) {
      emit(_state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  @override
  Future<void> loadOrders() async {
    if (state.isLoading) {
      return;
    }

    emit(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      final ordersResult = await _repository.loadOrders();

      emit(_state.copyWith(isLoading: false, orders: ordersResult));
    } catch (error) {
      emit(_state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  @override
  Future<void> addOrder(Order order) async {
    try {
      await _repository.addOrder(order);
      loadOrders();
    } catch (error) {
      emit(_state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }
}
