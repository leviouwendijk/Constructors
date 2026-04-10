// import HTML
// import DSL

// public enum HTMLScopeCollector {
//     public static func collect(
//         matching scope: ScopeIdentifier,
//         from nodes: HTMLFragment
//     ) -> HTMLFragment {
//         var out: HTMLFragment = []

//         for node in nodes {
//             append(
//                 node,
//                 matching: scope,
//                 into: &out
//             )
//         }

//         return out
//     }

//     private static func append(
//         _ node: any HTMLNode,
//         matching scope: ScopeIdentifier,
//         into out: inout HTMLFragment
//     ) {
//         switch node {
//         case let region as HTMLBundledRegion:
//             if region.scope == scope {
//                 out.append(contentsOf: region.children)
//             } else {
//                 for child in region.children {
//                     append(
//                         child,
//                         matching: scope,
//                         into: &out
//                     )
//                 }
//             }

//         case let element as HTMLElement:
//             for child in element.children {
//                 append(
//                     child,
//                     matching: scope,
//                     into: &out
//                 )
//             }

//         case let inline as HTMLInlineGroup:
//             for child in inline.children {
//                 append(
//                     child,
//                     matching: scope,
//                     into: &out
//                 )
//             }

//         case let gate as HTMLGate:
//             for child in gate.children {
//                 append(
//                     child,
//                     matching: scope,
//                     into: &out
//                 )
//             }

//         default:
//             break
//         }
//     }
// }
