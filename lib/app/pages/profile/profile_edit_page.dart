import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:odoo_client/app/data/services/login_facade_impl.dart';
import 'package:odoo_client/app/pages/profile/profile_edit_controller.dart';
import 'package:odoo_client/shared/components/container_tile.dart';
import 'package:odoo_client/shared/controllers/authentication_controller.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key key}) : super(key: key);
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  AuthenticationController _authenticationController;
  ProfileEditController _profileEditController;
  ReactionDisposer _updateProfileReaction;
  UserProfile _user;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _authenticationController = GetIt.I.get<AuthenticationController>();
    _profileEditController = GetIt.I.get<ProfileEditController>();
    _updateProfileReaction = reaction<FutureStatus>(
        (_) => _profileEditController.updateProfileRequest.status,
        _onUpdateUser);
    _initProfileData();
    super.initState();
  }

  void _initProfileData() {
    _user = _authenticationController.currentUser;
    _profileEditController.partnerId = _user.partnerId;
    _profileEditController.aboutYou = _user.profile_description;
    _profileEditController.function = _user.function;
    _profileEditController.gender = _user.gender;
    _profileEditController.birthdate = _user.birthdate_date;
  }

  void _onUpdateUser(FutureStatus requestStatus) {
    final response = _profileEditController.updateProfileRequest;
    switch (requestStatus) {
      case FutureStatus.fulfilled:
        _onSuccess(response.value);
        break;
      default:
    }
  }

  void _onSuccess(FutureStatus requestStatus) {
    _authenticationController.authenticate(_user.copyWith(
      profile_description: _profileEditController.aboutYou,
      function: _profileEditController.function,
      gender: _profileEditController.gender,
    ));

    _updateProfileReaction();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _profileEditController.submit();
        return true;
      },
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Color.fromRGBO(239, 242, 239, 1),
            appBar: AppBar(
              backgroundColor: Colors.black,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPhotoContainer(),
                  Column(
                    children: [
                      Container(
                        child: _buildTextFieldTile(
                          initialValue: _user.profile_description,
                          hintText: "Fale sobre você...",
                          onChanged: (e) {
                            _profileEditController.aboutYou = e;
                          },
                          title: "Sobre",
                          counter: 120,
                          hasArrowIndicator: false,
                        ),
                        height: 120,
                      ),
                      const SizedBox(height: 10),
                      _buildTile(
                          title: "Estilos de dança",
                          onTap: () async {
                            final result = await Navigator.of(context)
                                .pushNamed("/musical_preferences");
                            _profileEditController.danceStyles = result;
                          }),
                      const SizedBox(height: 10),
                      _buildTile(
                          title: "Nível de dança",
                          onTap: () async {
                            final result = await Navigator.of(context)
                                .pushNamed("/dance_level");
                            _profileEditController.danceLevel = result;
                          }),
                      const SizedBox(height: 10),
                      Container(
                        child: _buildTextFieldTile(
                          initialValue: _user.function,
                          hintText: "Diga a sua profissão...",
                          onChanged: (e) {
                            _profileEditController.function = e;
                          },
                          title: "Profissão",
                        ),
                        height: 70,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime(DateTime.now().year - 18, 1, 1),
                              firstDate:
                                  DateTime(DateTime.now().year - 18, 1, 1),
                              lastDate: DateTime.now(),
                            );
                            _profileEditController.birthdate = date;
                          },
                          child: _buildContainer(
                              title: "Data de nascimento",
                              subtitle:
                                  "${DateFormat.yMd().format(_profileEditController.birthdate)}"),
                        ),
                        height: 70,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.of(context)
                                .pushNamed("/genree");
                            _profileEditController.gender = result;
                          },
                          child: Observer(builder: (_) {
                            return _buildContainer(
                              subtitle: "${_profileEditController.gender}",
                              title: "Gênero",
                            );
                          }),
                        ),
                        height: 70,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer({String title, String subtitle}) {
    return ContainerTile(
        child: Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: const Color.fromRGBO(124, 127, 124, 1),
                  ),
                ),
                const SizedBox(height: 10),
                Text(subtitle,
                    style: const TextStyle(color: Colors.blue, fontSize: 15)),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: const Color.fromRGBO(227, 227, 224, 1),
          )
        ],
      ),
    ));
  }

  Widget _buildTextFieldTile(
      {String title,
      String hintText,
      TextStyle hintTextStyle,
      String initialValue,
      TextEditingController controller,
      void Function(String value) onChanged,
      int counter,
      bool enabled = true,
      bool hasArrowIndicator = true}) {
    return ContainerTile(
        child: Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: const Color.fromRGBO(124, 127, 124, 1),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: initialValue,
                    enabled: enabled,
                    controller: controller,
                    maxLines: null,
                    maxLength: 120,
                    onChanged: onChanged,
                    maxLengthEnforced: true,
                    buildCounter: (context,
                            {int currentLength,
                            bool isFocused,
                            int maxLength}) =>
                        Container(
                      width: 0,
                      height: 0,
                    ),
                    decoration: InputDecoration.collapsed(
                        hintText: hintText,
                        hintStyle: hintTextStyle,
                        floatingLabelBehavior: FloatingLabelBehavior.never),
                  ),
                ),
                if (counter != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "$counter",
                      style: const TextStyle(
                        color: const Color.fromRGBO(124, 127, 124, 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (hasArrowIndicator)
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color.fromRGBO(227, 227, 224, 1),
            )
        ],
      ),
    ));
  }

  Widget _buildTile({String title, VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ContainerTile(
          child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 13),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: const Color.fromRGBO(124, 127, 124, 1),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color.fromRGBO(227, 227, 224, 1),
            )
          ],
        ),
      )),
    );
  }

  Widget _buildPhotoContainer() {
    return Container(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      color: Color.fromRGBO(239, 242, 239, 1),
      child: Container(
        height: 230,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: _buildRoundedImage(
                  icon: Icon(Icons.close, color: Colors.white),
                  onTap: () {},
                  imageBytes: null),
            ),
            Flexible(
              child: Column(
                children: [
                  Expanded(
                    child: _buildRoundedImage(
                        icon: Icon(Icons.close, color: Colors.white),
                        onTap: () {},
                        imageBytes: null),
                  ),
                  Expanded(
                    child: _buildRoundedImage(
                        icon: Icon(Icons.close, color: Colors.white),
                        onTap: () {},
                        imageBytes: null),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedImage({
    Widget icon,
    VoidCallback onTap,
    List<int> imageBytes,
  }) {
    return Stack(
      overflow: Overflow.visible,
      children: [
        Container(color: Colors.transparent),
        Padding(
          padding: const EdgeInsets.all(7),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            child: Container(
                color: const Color.fromRGBO(201, 204, 201, 1),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        fit: BoxFit.fill,
                      )
                    : null),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              backgroundColor: const Color.fromRGBO(253, 0, 236, 1),
              radius: 15,
              child: icon,
            ),
          ),
        ),
      ],
    );
  }
}
