with builtins;
p:
  let l = p.lib; in
  rec
  { bundle =
      purescript:
      { entry-point
      , esbuild ? {}
      , output ? null
      , main ? true
      }:
      let
        esbuild' =
          { format = "esm";
            log-level = "warning";
          }
          // esbuild
          // { bundle = true;
               outfile = output;
             };

        flags =
          toString
            (l.mapAttrsToList
               (n: v:
                  if isBool v then
                    if v then "--${n}" else ""
                  else
                    "--${n}=${toString v}"
               )
               esbuild'
            );

        build = "${p.esbuild}/bin/esbuild ${flags}";
      in
      if main
      then ''echo 'import { main } from "${entry-point}"; main()' | ${build}''
      else ''${build} ${entry-point}'';


    compile =
      purescript:
      { globs
      , output ? null
      , verbose-errors ? false
      , comments ? false
      , codegen ? null
      , no-prefix ? false
      , json-errors ? false
      }:
      let
        flags =
          concatStringsSep " "
            [ (make-flag "--output " output)
              (make-flag "--verbose-errors" verbose-errors)
              (make-flag "--comments" comments)
              (make-flag "--codegen " codegen)
              (make-flag "--no-prefix" no-prefix)
              (make-flag "--json-errors" no-prefix)
            ];
      in
      ''${purescript}/bin/purs compile ${flags} ${globs}'';

    make-flag = flag: arg:
      if arg == null || arg == false then
        ""
      else if arg == true then
        flag
      else
        flag + arg;

    make-name = name: version:
      if version == null then
        { inherit name; }
      else
        { pname = name; inherit version; };

    package-info = pkg:
      ''
      echo "name:    ${pkg.pname or pkg.name}"
      echo "version: ${pkg.version or "none"}"
      echo "repo:    ${pkg.repo}"
      echo "commit:  ${pkg.rev}"
      echo "source:  ${pkg}"
      '';

    # subtract-string "abcdef" "abc" => "def"
    subtract-string = s1: s2:
      assert l.hasPrefix s2 s1;
      let
        l1 = stringLength s1;
        l2 = stringLength s2;
      in
      substring l2 (l1 - l2) s1;
  }
