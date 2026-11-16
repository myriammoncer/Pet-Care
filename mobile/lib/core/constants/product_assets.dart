/// Constantes et utilitaires pour les assets de la Marketplace
class ProductAssets {
  ProductAssets._();

  // ─── ALIMENTATION (10 images) ───
  static const String alimentationDogFood =
      'assets/images/marketplace/alimentation/DogFood.jpg';
  static const String alimentationAdobeStock =
      'assets/images/marketplace/alimentation/AdobeStock_161582709.jpeg';
  static const String alimentationChatGpt =
      'assets/images/marketplace/alimentation/ChatGPT-Image-4-sept.-2025-18_00_57-1280x853.png';
  static const String alimentationDietGuide =
      'assets/images/marketplace/alimentation/dog-food-allergies-yeast-diet-guide-pmp.webp';
  static const String alimentationGoldPatee =
      'assets/images/marketplace/alimentation/gold-patee-honey-fusion-nutribird-versele-laga.jpg';
  static const String alimentationCroquettesChats =
      'assets/images/marketplace/alimentation/meilleurs-croquettes-pour-chats-comparatif-header-mobile.jpg';
  static const String alimentationPackDecouverte =
      'assets/images/marketplace/alimentation/pack-decouverte-made-in-france-alimentation-pour-chien.jpg';
  static const String alimentationImages =
      'assets/images/marketplace/alimentation/images.jpg';
  static const String alimentationImages1 =
      'assets/images/marketplace/alimentation/images (1).jpg';
  static const String alimentationImages2 =
      'assets/images/marketplace/alimentation/images (2).jpg';

  static const List<String> listAlimentation = [
    alimentationDogFood,
    alimentationPackDecouverte,
    alimentationCroquettesChats,
    alimentationGoldPatee,
    alimentationAdobeStock,
    alimentationChatGpt,
    alimentationDietGuide,
    alimentationImages,
    alimentationImages1,
    alimentationImages2,
  ];

  // ─── JOUETS (5 images) ───
  static const String jouetsBalle =
      'assets/images/marketplace/jouets/cc587551-1933-4a44-af53-9662d381085c.jpg';
  static const String jouetsPeluche =
      'assets/images/marketplace/jouets/PELUCHE-SUR-MESURE-JAPHY-BEASTIZZ.jpg';
  static const String jouets3009665 =
      'assets/images/marketplace/jouets/3009665_73.jpg';
  static const String jouets61BT =
      'assets/images/marketplace/jouets/61BTxkFttYL.jpg';
  static const String jouetsVoDb =
      'assets/images/marketplace/jouets/VoDb48M9IEfv5qRk21Fu7dm0pMUeeRaMhtRdDa45.jpg';

  static const List<String> listJouets = [
    jouetsBalle,
    jouetsPeluche,
    jouets3009665,
    jouets61BT,
    jouetsVoDb,
  ];

  // ─── COUCHAGE & NICHE (6 images) ───
  static const String couchageNicheBois =
      'assets/images/marketplace/couchage/Niche-de-chien-en-bois-Dogue-de-Bordeaux.jpg';
  static const String couchageOriginal =
      'assets/images/marketplace/couchage/c9635653c1ccc747ca09a947052f637fd9ba4624_original.jpeg';
  static const String couchageIstock1125 =
      'assets/images/marketplace/couchage/istockphoto-1125630990-612x612.jpg';
  static const String couchageIstock1736 =
      'assets/images/marketplace/couchage/istockphoto-173656433-612x612.jpg';
  static const String couchage61peyr =
      'assets/images/marketplace/couchage/61peyr242mL._AC_UF1000,1000_QL80_.jpg';
  static const String couchage71kU =
      'assets/images/marketplace/couchage/71kUAVpKoaL._AC_UL375_SR375,375_.jpg';

  static const List<String> listCouchage = [
    couchageNicheBois,
    couchageOriginal,
    couchageIstock1125,
    couchageIstock1736,
    couchage61peyr,
    couchage71kU,
  ];

  // ─── HYGIÈNE & SOINS (5 images) ───
  static const String hygieneShampooings =
      'assets/images/marketplace/hygiene/Shampooings-lingettes-chats-1.jpg';
  static const String hygieneCh7020 =
      'assets/images/marketplace/hygiene/ch7020_25.jpeg';
  static const String hygieneImages =
      'assets/images/marketplace/hygiene/images.jpg';
  static const String hygieneImages1 =
      'assets/images/marketplace/hygiene/images (1).jpg';
  static const String hygieneImages2 =
      'assets/images/marketplace/hygiene/images (2).jpg';

  static const List<String> listHygiene = [
    hygieneShampooings,
    hygieneCh7020,
    hygieneImages,
    hygieneImages1,
    hygieneImages2,
  ];

  // ─── ACCESSOIRES (5 images) ───
  static const String accessoiresCollierLaisse =
      'assets/images/marketplace/accessoires/chien_promenade_collier_rouge_personnalise_laisse.png';
  static const String accessoires715554235 =
      'assets/images/marketplace/accessoires/715554235.jpg';
  static const String accessoiresImages =
      'assets/images/marketplace/accessoires/images.jpg';
  static const String accessoiresImages1 =
      'assets/images/marketplace/accessoires/images (1).jpg';
  static const String accessoiresImages2 =
      'assets/images/marketplace/accessoires/images (2).jpg';

  static const List<String> listAccessoires = [
    accessoiresCollierLaisse,
    accessoires715554235,
    accessoiresImages,
    accessoiresImages1,
    accessoiresImages2,
  ];

  // ─── TRANSPORT (1 image) ───
  static const String transportSac =
      'assets/images/marketplace/transport/sac_transport.jpg';

  static const List<String> listTransport = [
    transportSac,
  ];

  /// Résolution intelligente de l'image locale d'un produit.
  /// Attribue une image DISTINCTE et variée selon le nom/id du produit.
  static String resolveAsset(String? photoUrl, String? category, [String? identifier]) {
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      final p = photoUrl.trim();
      // Si c'est déjà un chemin d'asset direct et valide
      if (p.startsWith('assets/images/marketplace/')) {
        return p;
      }
      // Si l'URL contient un mot-clé précis
      final lower = p.toLowerCase();
      if (lower.contains('dogfood')) return alimentationDogFood;
      if (lower.contains('croquette')) return alimentationCroquettesChats;
      if (lower.contains('patee')) return alimentationGoldPatee;
      if (lower.contains('balle')) return jouetsBalle;
      if (lower.contains('peluche')) return jouetsPeluche;
      if (lower.contains('niche')) return couchageNicheBois;
      if (lower.contains('coussin')) return couchageOriginal;
      if (lower.contains('shampoing') || lower.contains('hygiene')) return hygieneShampooings;
      if (lower.contains('laisse') || lower.contains('collier')) return accessoiresCollierLaisse;
      if (lower.contains('transport')) return transportSac;
    }

    // Récupération de la liste des images de la catégorie
    final list = _getListForCategory(category);
    if (list.isEmpty) return alimentationDogFood;

    // Si on a un identifiant (nom ou id), on sélectionne une image unique
    if (identifier != null && identifier.isNotEmpty) {
      final index = identifier.hashCode.abs() % list.length;
      return list[index];
    }

    return list.first;
  }

  static List<String> _getListForCategory(String? category) {
    if (category == null) return listAlimentation;
    final cat = category.toUpperCase();
    if (cat.contains('ALIMENT')) return listAlimentation;
    if (cat.contains('JOUET')) return listJouets;
    if (cat.contains('NICH') || cat.contains('COUCH')) return listCouchage;
    if (cat.contains('HYGIEN') || cat.contains('SOIN')) return listHygiene;
    if (cat.contains('ACCESSOIR')) return listAccessoires;
    if (cat.contains('TRANSPORT')) return listTransport;
    return listAlimentation;
  }
}
