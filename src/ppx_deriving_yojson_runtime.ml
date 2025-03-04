include Ppx_deriving_runtime

let (>>=) x f =
  match x with Result.Ok x -> f x | (Result.Error _) as x -> x

let (>|=) x f =
  x >>= fun x -> Result.Ok (f x)

let rec map_bind f acc xs =
  match xs with
  | x :: xs ->
    (* equivalent to [f x >>= fun x -> map_bind f (x :: acc) xs],
       but do not use [(>>=)] to keep [map_bind] tail-recursive
       under js-of-ocaml *)
    (match f x with
     | ((Result.Error _) as err) -> err
     | Result.Ok x -> map_bind f (x :: acc) xs)
  | [] -> Result.Ok (List.rev acc)

type 'a error_or = ('a, string) Stdlib.result

(** [safe_map f l] returns the same value as [List.map f l], but
    computes it tail-recursively so that large list lengths don't
    cause a stack overflow *)
let safe_map f l = List.rev (List.rev_map f l)
