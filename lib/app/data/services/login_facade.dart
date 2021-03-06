import 'package:odoo_client/app/data/models/login_dto.dart';
import 'package:odoo_client/app/data/models/login_result.dart';
import 'package:odoo_client/app/data/services/login_facade_impl.dart';

abstract class LoginFacade{
  Future<LoginResult> login(LoginDto loginDto);
}