
class Archive {
  Archive();

  final Set<int> _achivements = {};

  List<int> get achivements => _achivements.toList();

  void addAchivement(int achivementId) {
    _achivements.add(achivementId);
  }
}

class AchivementData {
  // load achivement images and string datas
  
}