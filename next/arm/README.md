# ARM Repositories Layers

For ARM architecture Sabayon team expose different layers as repositories, in particular there are these repositories:

 * **core-arm**: it contains core packages for Sabayon (gcc, binutils, portage, systemd, etc.).
   The idea is to maintain at this level minimal use flags required from the base-arm layer.

 * **base-arm**: it contains all dev-lang/\* stuff and main dev-libs/\* stuff.
   At this layer we have -X as use flag.

 * **xorg-core-arm**: it contains all xorg packages commons.

 * **kde-arm**: it contains all kde and qt packages.

 * **gtk-arm**: it contains all gnome and gtk+ packages

 * **xorgs-apps-arm**: it contains all packages related to both qt and gtk+ and any ohers DE
   (lxqt, xfce, enlightenment, etc.)

 * **net-arm**: it contains all networks, servers packages (etcd, lxd, openstack stuff, etc.)

 * **devel-arm**: it contains all development stuff (pkg-checker, sabayon-sark, devkit, etc.)

 * **sabayon-arm**: it contains entropy stuff (rigo, equo, entropy, entropy-server)
