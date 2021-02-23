import 'dart:developer';

import 'package:odoo_client/app/data/models/like_dto.dart';
import 'package:odoo_client/app/data/services/odoo_api.dart';
import 'package:odoo_client/app/data/services/relation_service.dart';

class RelationServiceImpl implements RelationService {
  final Odoo _odoo;

  RelationServiceImpl(this._odoo);

  @override
  Future findMatches() {
    // TODO: implement findMatches
    throw UnimplementedError();
  }

  @override
  Future<void> sendDeslike() {
    // TODO: implement sendDeslike
    throw UnimplementedError();
  }

  @override
  Future<void> sendLike(LikeDto likeDto) async {
    final relationTypeResponse =
        await _odoo.searchRead('res.partner.relation.type', [
      ['name', '=', 'Send Likes']
    ], [
      'id'
    ]);
    final relationTypeId = relationTypeResponse.getRecords()[0]["id"];

    final createRelationResponse = await _odoo.create('res.partner.relation', {
      'left_partner_id': likeDto.currentUserPartnerId,
      'right_partner_id': likeDto.friendPartnerId,
      'type_id': relationTypeId,
    });
    log("${createRelationResponse.getRecords()}");
  }
}