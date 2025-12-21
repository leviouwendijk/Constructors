extension SiteObject {
    // because of the struct type gynmnastics this now exposes the link methods
    // under the 'dynamiclink' namespaced API
    // examples:
    //      .dynamiclink.base()
    //      .dynamiclink.sub()
    //      .dynamiclink.build(...args)
    public static var dynlink: SiteDynamicLink<Self> {
        SiteDynamicLink<Self>()
    }
}
// now redundant with enforced type checking?
