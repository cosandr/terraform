resource "hcloud_ssh_key" "desktop" {
  name       = "andrei@desktop"
  public_key = file("~/.local/share/chezmoi/private_dot_ssh/private_desktop_ed25519.pub")
}

resource "hcloud_ssh_key" "laptop" {
  name       = "andrei@laptop"
  public_key = file("~/.local/share/chezmoi/private_dot_ssh/private_laptop_ed25519.pub")
}
