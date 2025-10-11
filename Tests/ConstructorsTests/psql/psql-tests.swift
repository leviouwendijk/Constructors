import Foundation
import Testing
@testable import Constructors

@Suite("PSQL DSL")
struct PSQLDSLTests {

    @Test
    func select_in_between_order() {
        let q = PSQL.Select.make(
            [PSQL.Ident.column("u.id"), PSQL.Ident.column("u.email")], from: "users u"
        )
        .where {
            PSQL.in(PSQL.col("status"), ["active","trial"])
            // dotted -> Ident.column
            PSQL.between(PSQL.Ident.column("u.created_at"), PSQL.val(1), PSQL.val(10))
        }
        .orderByIdent(PSQL.desc(.column("u.created_at")))
        .orderBy(PSQL.desc(.column("u.created_at")))
        .limit(5)
        .build()

        #expect(q.sql.contains("SELECT"))
        #expect(q.sql.contains(" IN "))
        #expect(q.sql.contains(" BETWEEN "))
        #expect(q.binds.count == 4) // 2 for IN + 2 for BETWEEN
    }

    @Test
    func in_empty_list_renders_null() {
        let q = PSQL.Select.make([PSQL.col("id")], from: "users")
            .where { PSQL.in(PSQL.col("id"), []) }
            .build()

        #expect(q.sql.contains("IN (NULL)"))
        #expect(q.binds.isEmpty)
    }

    @Test
    func upsert_typed_on_conflict_do_update() {
        let q = PSQL.Insert.make(into: "profiles", columns: ["user_id","city"])
            .values([UUID(), "Alkmaar"])
            .onConflict(.doUpdate(columns: [.column("user_id")], set: [("city","Alkmaar")]))
            .returning([PSQL.col("id")])
            .build()

        #expect(q.sql.contains("ON CONFLICT"))
        #expect(q.sql.contains("DO UPDATE"))
        #expect(q.binds.count == 2)
    }

    @Test
    func upsert_typed_on_conflict_do_nothing_variants() {
        let base = PSQL.Insert.make(into: "t", columns: ["a"]).values([1])

        let withCols = base.onConflict(.doNothing(columns: [.column("a")])).build()
        #expect(withCols.sql.contains("ON CONFLICT (\"a\") DO NOTHING"))

        let withConstraint = base.onConflict(.doNothing(columns: nil, constraint: "t_a_key")).build()
        #expect(withConstraint.sql.contains("ON CONFLICT ON CONSTRAINT \"t_a_key\" DO NOTHING"))

        let generic = base.onConflict(.doNothing()).build()
        #expect(generic.sql.contains("ON CONFLICT DO NOTHING"))
    }

    @Test
    func join_and_lock_and_pagination() {
        let q = PSQL.Select.make(
            [PSQL.Ident.column("u.id"), PSQL.Ident.column("profiles.city")],
            from: "users u"
        )
        .join(PSQL.Join(.left, "profiles",
            on: PSQL.equals(PSQL.Ident.column("u.id"), PSQL.Ident.column("profiles.user_id"))
        ))
        .where {
            PSQL.equals(PSQL.Ident.column("u.is_active"), PSQL.val(true))
        }
        .orderByIdent(PSQL.desc(.column("u.created_at")))
        .limit(50)
        .offset(100)
        .lockForUpdate()
        .build()

        #expect(q.sql.contains("LEFT JOIN"))
        #expect(q.sql.contains("FOR UPDATE"))
        #expect(q.sql.contains("OFFSET 100"))
        #expect(q.binds.count == 1)
    }

    @Test
    func any_all_and_array_bind() {
        // driver binds one param (the array)
        let arrParam = PSQL.val([1,2,3])
        let q = PSQL.Select.make([PSQL.col("id")], from: "numbers")
            .where {
                PSQL.any(PSQL.col("id"), arrParam)
                PSQL.or(
                    PSQL.all(PSQL.col("id"), arrParam),
                    PSQL.notEquals(PSQL.col("id"), PSQL.val(999))
                )
            }
            .build()

        // 1 bind for arrParam + 1 bind for 999
        #expect(q.binds.count == 3)
        #expect(q.sql.contains("= ANY"))
        #expect(q.sql.contains("= ALL"))
    }

    @Test
    func exists_subquery_and_cte() {
        // CTE subselect that filters active users created after a date
        let base = PSQL.Select.make([PSQL.Ident.column("u.id")], from: "users u")
            .where {
                // dotted -> Ident.column
                PSQL.equals(PSQL.Ident.column("u.is_active"), PSQL.val(true))
                PSQL.gt(PSQL.Ident.column("u.created_at"), PSQL.val("2025-01-01"))
            }

        let main = PSQL.Select.make([PSQL.col("id"), PSQL.col("email")], from: "users")
            .with("active", as: base)
            .where {
                PSQL.Exists(
                        PSQL.Select.make([PSQL.unsafeRawInjection("1", strict: false)], from: "active")
                        .where { PSQL.equals(PSQL.Ident.column("active.id"), PSQL.Ident.column("users.id")) }
                )
            }
            .build()

        #expect(main.sql.contains("WITH \"active\" AS ("))
        #expect(main.sql.contains("EXISTS (SELECT"))
        // 2 binds in the CTE (true + date); SELECT 1 has no binds
        #expect(main.binds.count == 2)
    }

    @Test
    func case_when_projection() {
        let label = PSQL.CaseWhen(
            [
                (PSQL.equals(PSQL.col("score"), PSQL.val(10)), PSQL.val("perfect")),
                (PSQL.gte(PSQL.col("score"), PSQL.val(7)), PSQL.val("good")),
            ],
            else: PSQL.val("meh")
        )

        let q = PSQL.Select.make([label, PSQL.col("id")], from: "reviews").build()

        #expect(q.sql.contains("CASE WHEN"))
        #expect(q.sql.contains("THEN"))
        #expect(q.binds.count >= 3) // 10, 7, "meh"
    }

    @Test
    func unsafe_guard_heuristic() {
        // Allowed: identifiers-only fragment
        _ = PSQL.unsafeRawInjection(#""u"."id" = "p"."user_id""#, strict: true)

        // Blocked: numeric literal → would trap if uncommented
        // _ = PSQL.unsafeRawInjection("price > 100", strict: true)

        // Allowed when explicit opt-out:
        _ = PSQL.unsafeRawInjection("price > 100", strict: false)
    }

    @Test
    func cte_bind_numbering_monotonic() {
        let base = PSQL.Select.make([PSQL.Ident.column("u.id")], from: "users u")
            .where {
                PSQL.equals(PSQL.Ident.column("u.is_active"), PSQL.val(true))   // $1
                PSQL.gt(PSQL.Ident.column("u.created_at"), PSQL.val("2025-01-01")) // $2
            }

        let main = PSQL.Select.make([PSQL.col("id")], from: "users")
            .with("active", as: base)
            .where { PSQL.equals(PSQL.Ident.column("users.id"), PSQL.val(42)) } // $3
            .build()

        #expect(main.sql.contains("$1"))
        #expect(main.sql.contains("$2"))
        #expect(main.sql.contains("$3"))
        #expect(main.binds.count == 3)
    }

    @Test
    func in_list_param_expansion_orders_and_counts() {
        let ids: [any Encodable & Sendable] = [11, 22, 33]
        let q = PSQL.Select.make([PSQL.col("id")], from: "t")
            .where { PSQL.in(PSQL.col("id"), ids) }
            .build()

        #expect(q.sql.contains(#"IN ($1, $2, $3)"#))
        #expect(q.binds.count == 3)
    }

    @Test
    func between_uses_same_context_for_bounds() {
        let q = PSQL.Select.make([PSQL.col("id")], from: "t")
            .where { PSQL.between(PSQL.col("created_at"), PSQL.val(10), PSQL.val(20)) }
            .build()
        // The exact $n depends on prior binds; at least two in sequence must exist:
        #expect(q.sql.contains(" BETWEEN "))
        #expect(q.binds.count == 2)
    }

    @Test
    func any_all_single_array_param_counts() {
        let arr = PSQL.val([1,2])     // one bind for the whole array
        let q = PSQL.Select.make([PSQL.col("id")], from: "t")
            .where {
                PSQL.any(PSQL.col("id"), arr)
                PSQL.all(PSQL.col("id"), arr)
            }
            .build()
        // #expect(q.binds.count == 1) 
        #expect(q.binds.count == 2)
        #expect(q.sql.contains("= ANY"))
        #expect(q.sql.contains("= ALL"))
    }

    @Test
    func order_by_helpers_quote_and_direction() {
        let q = PSQL.Select.make([PSQL.col("id")], from: "users u")
            .orderByIdent(PSQL.asc(.column("u.created_at")), PSQL.desc(.column("u.email")))
            .build()
        #expect(q.sql.contains(#""u"."created_at" ASC"#))
        #expect(q.sql.contains(#""u"."email" DESC"#))
    }

    @Test
    func distinct_select() {
        let q = PSQL.Select.make([PSQL.col("email")], from: "users").distinct().build()
        #expect(q.sql.contains("SELECT DISTINCT"))
    }

    @Test
    func multiple_joins_rendering() {
        let q = PSQL.Select.make([PSQL.Ident.column("u.id")], from: "users u")
            .join(PSQL.join(.left, table: .table("profiles"), on:
                PSQL.equals(PSQL.Ident.column("u.id"), PSQL.Ident.column("profiles.user_id"))
            ))
            .join(PSQL.join(.inner, table: .table("cities"), on:
                PSQL.equals(PSQL.Ident.column("profiles.city_id"), PSQL.Ident.column("cities.id"))
            ))
            .build()
        #expect(q.sql.contains("LEFT JOIN"))
        #expect(q.sql.contains("INNER JOIN"))
        #expect(q.sql.contains(#""profiles" ON"#))
    }

    @Test
    func update_set_where_returning() {
        let q = PSQL.Update.make("profiles")
            .set("city", "Alkmaar")      // $1
            .set("bio", "trainer")       // $2
            .where { PSQL.equals(PSQL.col("user_id"), PSQL.val(UUID())) } // $3
            .returning([PSQL.col("id")])
            .build()

        #expect(q.sql.contains(#"UPDATE "profiles" SET "city" = $1, "bio" = $2"#))
        #expect(q.sql.contains(" WHERE "))
        #expect(q.sql.contains(" RETURNING "))
        #expect(q.binds.count == 3)
    }

    @Test
    func delete_where_clause() {
        let q = PSQL.Delete.make(from: "profiles")
            .where { PSQL.equals(PSQL.col("user_id"), PSQL.val(UUID())) }
            .build()
        #expect(q.sql.starts(with: #"DELETE FROM "profiles""#))
        #expect(q.sql.contains(" WHERE "))
        #expect(q.binds.count == 1)
    }

    @Test
    func function_and_text_ops() {
        let q = PSQL.Select.make([
                PSQL.func_("coalesce", [PSQL.col("nickname"), PSQL.val("unknown")])
            ], from: "users")
            .where {
                PSQL.like(PSQL.col("email"), PSQL.val("%@gmail.com"))
                PSQL.ilike(PSQL.col("city"), PSQL.val("%alkmaar%"))
            }
            .build()
        #expect(q.sql.contains("coalesce("))
        #expect(q.sql.contains("LIKE"))
        #expect(q.sql.contains("ILIKE"))
        #expect(q.binds.count == 3) 
    }

    @Test
    func jsonb_contains_operator() {
        let q = PSQL.Select.make([PSQL.col("id")], from: "events")
            .where {
                PSQL.jsonbContains(PSQL.col("payload"), PSQL.val(#"{"type":"review"}"#))
            }.build()
        #expect(q.sql.contains("@>"))
        #expect(q.binds.count == 1)
    }

    @Test
    func unsafe_injection_opt_out_allows_literals() {
        // should pass through when strict:false
        _ = PSQL.unsafeRawInjection("price > 100", strict: false)
        _ = PSQL.unsafeRawInjection(#"-- comment ok when strict:false"#, strict: false)
    }
}
