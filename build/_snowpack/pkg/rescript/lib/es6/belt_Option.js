import { _ as __1, a as __2 } from '../../../common/curry-dd33ed00.js';
import { v as valFromOption, s as some } from '../../../common/caml_option-f59fd915.js';

function keepU(opt, p) {
  if (opt !== undefined && p(valFromOption(opt))) {
    return opt;
  }
  
}

function keep(opt, p) {
  return keepU(opt, __1(p));
}

function forEachU(opt, f) {
  if (opt !== undefined) {
    return f(valFromOption(opt));
  }
  
}

function forEach(opt, f) {
  return forEachU(opt, __1(f));
}

function getExn(x) {
  if (x !== undefined) {
    return valFromOption(x);
  }
  throw {
        RE_EXN_ID: "Not_found",
        Error: new Error()
      };
}

function mapWithDefaultU(opt, $$default, f) {
  if (opt !== undefined) {
    return f(valFromOption(opt));
  } else {
    return $$default;
  }
}

function mapWithDefault(opt, $$default, f) {
  return mapWithDefaultU(opt, $$default, __1(f));
}

function mapU(opt, f) {
  if (opt !== undefined) {
    return some(f(valFromOption(opt)));
  }
  
}

function map(opt, f) {
  return mapU(opt, __1(f));
}

function flatMapU(opt, f) {
  if (opt !== undefined) {
    return f(valFromOption(opt));
  }
  
}

function flatMap(opt, f) {
  return flatMapU(opt, __1(f));
}

function getWithDefault(opt, $$default) {
  if (opt !== undefined) {
    return valFromOption(opt);
  } else {
    return $$default;
  }
}

function isSome(param) {
  return param !== undefined;
}

function isNone(x) {
  return x === undefined;
}

function eqU(a, b, f) {
  if (a !== undefined) {
    if (b !== undefined) {
      return f(valFromOption(a), valFromOption(b));
    } else {
      return false;
    }
  } else {
    return b === undefined;
  }
}

function eq(a, b, f) {
  return eqU(a, b, __2(f));
}

function cmpU(a, b, f) {
  if (a !== undefined) {
    if (b !== undefined) {
      return f(valFromOption(a), valFromOption(b));
    } else {
      return 1;
    }
  } else if (b !== undefined) {
    return -1;
  } else {
    return 0;
  }
}

function cmp(a, b, f) {
  return cmpU(a, b, __2(f));
}
/* No side effect */

export { cmp, cmpU, eq, eqU, flatMap, flatMapU, forEach, forEachU, getExn, getWithDefault, isNone, isSome, keep, keepU, map, mapU, mapWithDefault, mapWithDefaultU };
