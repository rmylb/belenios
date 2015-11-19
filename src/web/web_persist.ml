(**************************************************************************)
(*                                BELENIOS                                *)
(*                                                                        *)
(*  Copyright © 2012-2015 Inria                                           *)
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

open Lwt
open Serializable_builtin_j
open Serializable_j
open Common
open Web_serializable_j
open Web_common

type election_state =
  [ `Open
  | `Closed
  | `EncryptedTally of int * int * string
  | `Tallied of plaintext
  ]

let election_states = Ocsipersist.open_table "election_states"

let get_election_state x =
  try_lwt Ocsipersist.find election_states x
  with Not_found -> return `Open

let set_election_state x s =
  Ocsipersist.add election_states x s

let election_dates = Ocsipersist.open_table "election_dates"

let past = datetime_of_string "\"2015-10-01 00:00:00.000000\""

let get_election_date x =
  try_lwt Ocsipersist.find election_dates x
  with Not_found -> return past

let set_election_date x d =
  Ocsipersist.add election_dates x d

let election_pds = Ocsipersist.open_table "election_pds"

let get_partial_decryptions x =
  try_lwt Ocsipersist.find election_pds x
  with Not_found -> return []

let set_partial_decryptions x pds =
  Ocsipersist.add election_pds x pds

let auth_configs = Ocsipersist.open_table "auth_configs"

let get_auth_config x =
  try_lwt Ocsipersist.find auth_configs x
  with Not_found -> return []

let set_auth_config x c =
  Ocsipersist.add auth_configs x c

let ( / ) = Filename.concat

let get_raw_election uuid =
  try_lwt
    let lines = Lwt_io.lines_of_file (!spool_dir / uuid / "election.json") in
    begin match_lwt Lwt_stream.to_list lines with
    | x :: _ -> return @@ Some x
    | [] -> return_none
    end
  with _ -> return_none

let get_election_metadata uuid =
  try_lwt
    Lwt_io.chars_of_file (!spool_dir / uuid / "metadata.json") |>
    Lwt_stream.to_string >>= fun x ->
    return @@ Some (metadata_of_string x)
  with _ -> return_none

let get_election_result uuid =
  try_lwt
    Lwt_io.chars_of_file (!spool_dir / uuid / "result.json") |>
    Lwt_stream.to_string >>= fun x ->
    return @@ Some (result_of_string (Yojson.Safe.from_lexbuf ~stream:true) x)
  with _ -> return_none
