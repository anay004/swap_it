class UserModel {
  String? name;
  String? email;
  String? password;
  String? phone;
  String? userImage;

  UserModel(
      {
        this.name,
        this.email,
        this.password,
        this.phone,
        this.userImage
      });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    userImage: json['userImage'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phone'] = this.phone;
    data['userImage'] = this.userImage;
    return data;
  }
}