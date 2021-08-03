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

open Belenios_platform
open Platform
open Belenios_core
open Serializable_j
open Signatures

let get_ff_params = function
  | "BELENIOS-2048" ->
     {
       g = Z.of_string "2402352677501852209227687703532399932712287657378364916510075318787663274146353219320285676155269678799694668298749389095083896573425601900601068477164491735474137283104610458681314511781646755400527402889846139864532661215055797097162016168270312886432456663834863635782106154918419982534315189740658186868651151358576410138882215396016043228843603930989333662772848406593138406010231675095763777982665103606822406635076697764025346253773085133173495194248967754052573659049492477631475991575198775177711481490920456600205478127054728238140972518639858334115700568353695553423781475582491896050296680037745308460627";
       p = Z.of_string "20694785691422546401013643657505008064922989295751104097100884787057374219242717401922237254497684338129066633138078958404960054389636289796393038773905722803605973749427671376777618898589872735865049081167099310535867780980030790491654063777173764198678527273474476341835600035698305193144284561701911000786737307333564123971732897913240474578834468260652327974647951137672658693582180046317922073668860052627186363386088796882120769432366149491002923444346373222145884100586421050242120365433561201320481118852408731077014151666200162313177169372189248078507711827842317498073276598828825169183103125680162072880719";
       q = Z.of_string "78571733251071885079927659812671450121821421258408794611510081919805623223441";
       embedding = None;
     }
  | "RFC-3526-2048" ->
     {
       g = Z.of_string "2";
       p = Z.of_string "32317006071311007300338913926423828248817941241140239112842009751400741706634354222619689417363569347117901737909704191754605873209195028853758986185622153212175412514901774520270235796078236248884246189477587641105928646099411723245426622522193230540919037680524235519125679715870117001058055877651038861847280257976054903569732561526167081339361799541336476559160368317896729073178384589680639671900977202194168647225871031411336429319536193471636533209717077448227988588565369208645296636077250268955505928362751121174096972998068410554359584866583291642136218231078990999448652468262416972035911852507045361090559";
       q = Z.of_string "16158503035655503650169456963211914124408970620570119556421004875700370853317177111309844708681784673558950868954852095877302936604597514426879493092811076606087706257450887260135117898039118124442123094738793820552964323049705861622713311261096615270459518840262117759562839857935058500529027938825519430923640128988027451784866280763083540669680899770668238279580184158948364536589192294840319835950488601097084323612935515705668214659768096735818266604858538724113994294282684604322648318038625134477752964181375560587048486499034205277179792433291645821068109115539495499724326234131208486017955926253522680545279";
       embedding = Some {padding = 8; bits_per_int = 8};
     }
  | _ -> raise Not_found

let of_string x =
  match get_ff_params x with
  | exception Not_found ->
     Printf.ksprintf failwith "unknown group: %s" x
  | params ->
     let module G = (val Group_field.make params : Group_field.GROUP) in
     (module G : GROUP)
