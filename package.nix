{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "omnipoly";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "kWeglinski";
    repo = "OmniPoly";
    tag = "v${version}";
    hash = "sha256-Z1dVuCZ8agQLwNANE3kqlV0kCM+wma5Ri3SWlbEc7qk=";
  };

  npmDepsHash = "sha256-uuKEsTqQGt0wl/c9zz7cuN5VRI6AJ0hOK7v9UgiZQDw=";

  meta = {
    description = "Frontend for LanguageTool and LibreTranslate";
    homepage = "https://github.com/kWeglinski/OmniPoly";
    changelog = "https://github.com/kWeglinski/OmniPoly/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ encode42 ];
  };
}
