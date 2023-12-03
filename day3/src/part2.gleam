import gleam/io
import gleam/string
import gleam/iterator
import gleam/int
import gleam/list
import simplifile
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/dict.{type Dict}

pub type Cell {
  Number(n: Int)
  Symbol
  Gear
  Empty
}

pub fn parse_int(s: String) -> Int {
  let assert Ok(n) = int.base_parse(s, 10)
  n
}

pub fn proc_line(line: String) -> List(Cell) {
  line
  |> string.split("")
  |> iterator.from_list
  |> iterator.map(fn(c: String) {
    let res = case c {
      "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ->
        Number(parse_int(c))
      "." -> Empty
      "*" -> Gear
      _ -> Symbol
    }
    res
  })
  |> iterator.to_list
}

pub fn access(maze: List(List(Cell)), x: Int, y: Int) -> Cell {
  case list.at(maze, x) {
    Error(_) -> Empty
    Ok(line) ->
      case list.at(line, y) {
        Error(_) -> Empty
        Ok(cell) -> cell
      }
  }
}

pub type ScanLineState {
  ScanLineState(
    nums: List(Int),
    curnum: Option(Int),
    curok: Bool,
    cur_gears: Set(#(Int, Int)),
    gears: List(#(#(Int, Int), Int)),
  )
}

pub fn adj_symbol(maze: List(List(Cell)), x: Int, y: Int) -> Bool {
  iterator.from_list([-1, 0, 1])
  |> iterator.map(fn(dx) {
    iterator.from_list([-1, 0, 1])
    |> iterator.map(fn(dy) {
      case #(dx, dy) {
        #(0, 0) -> False
        _ ->
          case access(maze, x + dx, y + dy) {
            Symbol | Gear -> True
            _ -> False
          }
      }
    })
    |> iterator.any(fn(x) { x })
  })
  |> iterator.any(fn(x) { x })
}

pub fn adj_gears(maze: List(List(Cell)), x: Int, y: Int) -> Set(#(Int, Int)) {
  iterator.from_list([-1, 0, 1])
  |> iterator.map(fn(dx) {
    iterator.from_list([-1, 0, 1])
    |> iterator.map(fn(dy) {
      case #(dx, dy) {
        #(0, 0) -> #(-1, -1)
        _ ->
          case access(maze, x + dx, y + dy) {
            Gear -> #(x + dx, y + dy)
            _ -> #(-1, -1)
          }
      }
    })
  })
  |> iterator.flatten
  |> iterator.filter(fn(cord) {
    let #(x, y) = cord
    x >= 0 && y >= 0
  })
  |> iterator.to_list
  |> set.from_list
}

pub fn state_transition(
  state: ScanLineState,
  maze: List(List(Cell)),
  x: Int,
  y: Int,
) -> ScanLineState {
  let cell: Cell = access(maze, x, y)
  case cell {
    Number(n) -> {
      let new_num: Int = case state.curnum {
        None -> n
        Some(old) -> old * 10 + n
      }
      ScanLineState(
        nums: state.nums,
        curnum: Some(new_num),
        curok: state.curok || adj_symbol(maze, x, y),
        cur_gears: set.union(state.cur_gears, adj_gears(maze, x, y)),
        gears: state.gears,
      )
    }
    _ ->
      case state.curnum {
        None ->
          ScanLineState(
            nums: state.nums,
            curnum: None,
            curok: False,
            cur_gears: state.cur_gears,
            gears: state.gears,
          )
        Some(n) ->
          ScanLineState(
            nums: case state.curok {
              True -> list.append(state.nums, [n])
              False -> state.nums
            },
            curnum: None,
            curok: False,
            cur_gears: set.new(),
            gears: case state.curok {
              True ->
                state.cur_gears
                |> set.to_list
                |> iterator.from_list
                |> iterator.map(fn(cord) { #(cord, n) })
                |> iterator.to_list
                |> list.append(state.gears)
              False -> state.gears
            },
          )
      }
  }
}

pub fn finish(state: ScanLineState) -> Dict(#(Int, Int), List(Int)) {
  state.gears
  |> iterator.from_list
  |> iterator.fold(
    from: dict.new(),
    with: fn(d, gv) {
      let #(cord, n) = gv
      dict.update(
        d,
        cord,
        fn(old) {
          case old {
            None -> [n]
            Some(old) -> [n, ..old]
          }
        },
      )
    },
  )
}

pub fn main() {
  let file_path = "inputs/day3.in"
  let assert Ok(content) = simplifile.read(file_path)
  let maze: List(List(Cell)) =
    content
    |> string.split("\n")
    |> iterator.from_list
    |> iterator.map(fn(x) { proc_line(x) })
    |> iterator.to_list

  let hei = list.length(maze)

  let gear_info: Dict(#(Int, Int), List(Int)) =
    iterator.range(0, hei - 1)
    |> iterator.map(fn(i) {
      let assert Ok(line) = list.at(maze, i)
      let wid = list.length(line)

      iterator.range(0, wid)
      |> iterator.fold(
        from: ScanLineState(
          nums: [],
          curnum: None,
          curok: False,
          cur_gears: set.new(),
          gears: [],
        ),
        with: fn(state, j) { state_transition(state, maze, i, j) },
      )
      |> finish
    })
    |> iterator.fold(
      from: dict.new(),
      with: fn(old_dict, new_res) {
        new_res
        |> dict.to_list
        |> iterator.from_list
        |> iterator.fold(
          from: old_dict,
          with: fn(o_dict, n_val) {
            let #(cord, n_list) = n_val
            o_dict
            |> dict.update(
              cord,
              fn(old) {
                case old {
                  None -> n_list
                  Some(old) ->
                    n_list
                    |> list.append(old)
                }
              },
            )
          },
        )
      },
    )

  gear_info
  |> dict.values
  |> iterator.from_list
  |> iterator.map(fn(x) {
    case list.length(x) {
      2 ->
        x
        |> list.fold(from: 1, with: fn(acc, n) { acc * n })
      _ -> 0
    }
  })
  |> iterator.fold(from: 0, with: fn(acc, n) { acc + n })
  |> io.debug
}
