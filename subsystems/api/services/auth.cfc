component accessors=true {
  property securityService;

  public struct function logout() {
    securityService.createSession();
    return { "status" = "logged out" };
  }
}