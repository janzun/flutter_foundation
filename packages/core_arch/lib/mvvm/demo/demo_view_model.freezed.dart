// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'demo_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DemoUiState {

 bool get isLoading;// 页面是否处于网络加载状态
 String get username;// 用户基础信息
 int get counter;
/// Create a copy of DemoUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DemoUiStateCopyWith<DemoUiState> get copyWith => _$DemoUiStateCopyWithImpl<DemoUiState>(this as DemoUiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DemoUiState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.username, username) || other.username == username)&&(identical(other.counter, counter) || other.counter == counter));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,username,counter);

@override
String toString() {
  return 'DemoUiState(isLoading: $isLoading, username: $username, counter: $counter)';
}


}

/// @nodoc
abstract mixin class $DemoUiStateCopyWith<$Res>  {
  factory $DemoUiStateCopyWith(DemoUiState value, $Res Function(DemoUiState) _then) = _$DemoUiStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String username, int counter
});




}
/// @nodoc
class _$DemoUiStateCopyWithImpl<$Res>
    implements $DemoUiStateCopyWith<$Res> {
  _$DemoUiStateCopyWithImpl(this._self, this._then);

  final DemoUiState _self;
  final $Res Function(DemoUiState) _then;

/// Create a copy of DemoUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? username = null,Object? counter = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,counter: null == counter ? _self.counter : counter // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DemoUiState].
extension DemoUiStatePatterns on DemoUiState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DemoUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DemoUiState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DemoUiState value)  $default,){
final _that = this;
switch (_that) {
case _DemoUiState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DemoUiState value)?  $default,){
final _that = this;
switch (_that) {
case _DemoUiState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String username,  int counter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DemoUiState() when $default != null:
return $default(_that.isLoading,_that.username,_that.counter);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String username,  int counter)  $default,) {final _that = this;
switch (_that) {
case _DemoUiState():
return $default(_that.isLoading,_that.username,_that.counter);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String username,  int counter)?  $default,) {final _that = this;
switch (_that) {
case _DemoUiState() when $default != null:
return $default(_that.isLoading,_that.username,_that.counter);case _:
  return null;

}
}

}

/// @nodoc


class _DemoUiState implements DemoUiState {
  const _DemoUiState({this.isLoading = false, this.username = 'Guest', this.counter = 0});
  

@override@JsonKey() final  bool isLoading;
// 页面是否处于网络加载状态
@override@JsonKey() final  String username;
// 用户基础信息
@override@JsonKey() final  int counter;

/// Create a copy of DemoUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DemoUiStateCopyWith<_DemoUiState> get copyWith => __$DemoUiStateCopyWithImpl<_DemoUiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DemoUiState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.username, username) || other.username == username)&&(identical(other.counter, counter) || other.counter == counter));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,username,counter);

@override
String toString() {
  return 'DemoUiState(isLoading: $isLoading, username: $username, counter: $counter)';
}


}

/// @nodoc
abstract mixin class _$DemoUiStateCopyWith<$Res> implements $DemoUiStateCopyWith<$Res> {
  factory _$DemoUiStateCopyWith(_DemoUiState value, $Res Function(_DemoUiState) _then) = __$DemoUiStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String username, int counter
});




}
/// @nodoc
class __$DemoUiStateCopyWithImpl<$Res>
    implements _$DemoUiStateCopyWith<$Res> {
  __$DemoUiStateCopyWithImpl(this._self, this._then);

  final _DemoUiState _self;
  final $Res Function(_DemoUiState) _then;

/// Create a copy of DemoUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? username = null,Object? counter = null,}) {
  return _then(_DemoUiState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,counter: null == counter ? _self.counter : counter // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
