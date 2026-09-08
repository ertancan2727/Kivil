/// Kullanıcının VIP/üye olup olmadığını söyler.
///
/// TODO: Gerçek üyelik/ödeme sistemi kurulunca burası sunucudan
/// kullanıcının abonelik durumunu kontrol edecek şekilde değişecek.
/// Şimdilik üyelik sistemi olmadığı için herkes VIP değil kabul edilir.
class MembershipService {
  MembershipService._();

  static bool get isVip => false;
}
