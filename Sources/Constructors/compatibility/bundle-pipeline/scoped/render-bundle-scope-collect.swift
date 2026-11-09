// import HTML
// import CSS
// import JS
// import DSL

// public extension RenderBundle {
//     static func collect<Scope: ScopeIdentifying>(
//         scoped scope: Scope,
//         from source: any RenderContributing,
//         assets: [any ScopedRenderContributing] = []
//     ) -> RenderBundle {
//         collect(
//             scoped: scope.scope,
//             from: source,
//             assets: assets
//         )
//     }

//     static func collect(
//         scoped scope: ScopeIdentifier,
//         from source: any RenderContributing,
//         assets: [any ScopedRenderContributing] = []
//     ) -> RenderBundle {
//         let base = source.render_contribution()

//         let collectedHead = HTMLScopeCollector.collect(
//             matching: scope,
//             from: base.head
//         )

//         let collectedBody = HTMLScopeCollector.collect(
//             matching: scope,
//             from: base.body
//         )

//         let scopedAssetContribution = assets.reduce(
//             RenderContribution.empty
//         ) { partial, asset in
//             guard asset.scope == scope else {
//                 return partial
//             }

//             return partial.merging(
//                 asset.scoped_render_contribution()
//             )
//         }

//         let scopedHTMLContribution = RenderContribution(
//             head: collectedHead,
//             body: collectedBody,
//             stylesheet_bundle: CSSBundle(),
//             script_bundle: JSBundle()
//         )

//         return RenderBundle(
//             scopedHTMLContribution.merging(
//                 scopedAssetContribution
//             )
//         )
//     }
// }
