(**************************************************************************)
(*                                BELENIOS                                *)
(*                                                                        *)
(*  Copyright © 2012-2021 Inria                                           *)
(*                                                                        *)
(*  This program is free software: you can redistribute it and/or modify  *)
(*  it under the terms of the GNU Affero General Public License as        *)
(*  published by the Free Software Foundation, either version 3 of the    *)
(*  License, or (at your option) any later version, with the additional   *)
(*  exemption that compiling, linking, and/or using OpenSSL is allowed.   *)
(*                                                                        *)
(*  This program is distributed in the hope that it will be useful, but   *)
(*  WITHOUT ANY WARRANTY; without even the implied warranty of            *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *)
(*  Affero General Public License for more details.                       *)
(*                                                                        *)
(*  You should have received a copy of the GNU Affero General Public      *)
(*  License along with this program.  If not, see                         *)
(*  <http://www.gnu.org/licenses/>.                                       *)
(**************************************************************************)

open Lwt.Syntax
open Lwt

module Make (Web_services : Web_services_sig.S) (Pages_common : Pages_common_sig.S) (Web_auth : Web_auth_sig.S) = struct

let run_post_login_handler =
  Web_auth.register_pre_login_handler ~auth_system:"dummy"
    (fun uuid username_or_address _ ~state ->
      let site_or_election =
        match uuid with
        | None -> `Site
        | Some _ -> `Election
      in
      let* page = Pages_common.login_dummy site_or_election username_or_address ~state in
      return @@ Web_auth_sig.Html page
    )

let () =
  Eliom_registration.Any.register ~service:Web_services.dummy_post
    (fun () (state, name) ->
      run_post_login_handler ~state
        {
          Web_auth.post_login_handler =
            fun _ _ cont ->
            cont (Some name)
        }
    )

end