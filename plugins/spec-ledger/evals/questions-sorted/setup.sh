#!/usr/bin/env bash
# Fixture: a tiny ticketing backend (invented). Generated, do not edit by hand.
set -e
mkdir -p src/main/scala/ticketing src/test/scala/ticketing
cat > build.sbt <<'X'
name := "ticketing"
scalaVersion := "2.13.14"
libraryDependencies += "org.scalameta" %% "munit" % "1.0.0" % Test
X
cat > src/main/scala/ticketing/Reservation.scala <<'X'
package ticketing

import java.time.{Duration, Instant}

final case class Hold(seats: Set[String], createdAt: Instant)

object Reservation {
  // Seats are held for 15 minutes, then released.
  val HoldDuration: Duration = Duration.ofMinutes(15)

  def isExpired(hold: Hold, now: Instant): Boolean =
    now.isAfter(hold.createdAt.plus(HoldDuration))
}
X
cat > src/main/scala/ticketing/Cancellation.scala <<'X'
package ticketing

import java.time.{Duration, Instant}

final case class Order(id: String, amountPaid: BigDecimal, eventStart: Instant, cancelled: Boolean)
final case class Refund(amount: BigDecimal)

object Cancellation {
  def decide(order: Order, now: Instant): Either[String, Refund] =
    if (order.cancelled) Left("already cancelled")
    else {
      val untilEvent = Duration.between(now, order.eventStart)
      if (untilEvent.compareTo(Duration.ofHours(48)) < 0) Right(Refund(BigDecimal(0)))
      else if (untilEvent.compareTo(Duration.ofDays(7)) < 0) Right(Refund(order.amountPaid * 0.5))
      else Right(Refund(order.amountPaid))
    }
}
X
cat > src/main/scala/ticketing/Transfer.scala <<'X'
package ticketing

final case class Ticket(id: String, holder: String, transfers: Int)

object Transfer {
  // A ticket can be transferred once. Nothing else is checked.
  def transfer(ticket: Ticket, to: String): Either[String, Ticket] =
    if (ticket.transfers >= 1) Left("already transferred")
    else Right(ticket.copy(holder = to, transfers = ticket.transfers + 1))
}
X
cat > src/test/scala/ticketing/CancellationSpec.scala <<'X'
package ticketing

import java.time.Instant

class CancellationSpec extends munit.FunSuite {
  private val now = Instant.parse("2026-10-01T10:00:00Z")

  test("CNL-03: cancellation less than 48h before event gives no refund") {
    val order = Order("o1", BigDecimal(100), now.plusSeconds(36 * 3600), cancelled = false)
    assertEquals(Cancellation.decide(order, now), Right(Refund(BigDecimal(0))))
  }
}
X
mkdir -p docs/specs/features docs/specs/decisions
cat > docs/specs/INDEX.md <<'X'
# Spec index

| Area | File | Scenarios | tested | untested | ambiguous |
| --- | --- | --- | --- | --- | --- |
| Reservation | `features/reservation.md` | 2 | 0 | 2 | 0 |
| Cancellation | `features/cancellation.md` | 3 | 1 | 2 | 0 |
X
cat > docs/specs/LEDGER.md <<'X'
# Ledger

Append-only. One line per change of direction. Never edit or delete a past line; correct with a new one.

| ID | Date | Kind | Scenarios | Summary | ADR | Asked by |
| --- | --- | --- | --- | --- | --- | --- |
| L-0001 | 2026-09-01 | baseline | all | Baseline extracted from code | | |
X
cat > docs/specs/open-questions.md <<'X'
# Open questions

## OQ-01: Can a transferred ticket be transferred again?
- Logged: 2026-09-01, while mapping the transfer code
- Evidence: Transfer.scala allows exactly one transfer; no test covers it
- Affects: TRF-01
- Options: (A) one transfer only, (B) unlimited
- Status: open
- Decision owner: product
X
cat > docs/specs/features/reservation.md <<'X'
# Reservation

## RSV-01: Seats are held on reservation
Status: untested
Given seats are available
When an attendee reserves them
Then the seats are held for the attendee

## RSV-02: A hold expires after 15 minutes
Status: untested
Given a hold created 16 minutes ago
When the hold is checked
Then the hold is expired and the seats are released
X
cat > docs/specs/features/cancellation.md <<'X'
# Cancellation

## CNL-01: Full refund a week or more before the event
Status: untested
Given a confirmed order for an event starting in 10 days
When the attendee cancels the order
Then the refund equals the amount paid

## CNL-02: Half refund between 48 hours and 7 days
Status: untested
Given a confirmed order for an event starting in 4 days
When the attendee cancels the order
Then the refund is half of the amount paid

## CNL-03: No refund close to the event
Status: tested
Given a confirmed order for an event starting in 36 hours
When the attendee cancels the order
Then the refund amount is 0
X
cat > docs/specs/features/transfer.md <<'X'
# Transfer

## TRF-01: A ticket can be transferred once
Status: untested
Given a ticket that has never been transferred
When the holder transfers it to another attendee
Then the new attendee holds the ticket
And a second transfer is refused
X
cat >> docs/specs/open-questions.md <<'X'

## OQ-02: Is the 48-hour refund boundary inclusive?
- Logged: 2026-09-01, while mapping CNL-03
- Evidence: Cancellation.scala uses a strict "less than 48 hours"; no test covers exactly 48 hours
- Affects: CNL-02, CNL-03
- Options: (A) exactly 48h gets the half refund, (B) exactly 48h gets nothing
- Status: open
- Decision owner: product
X
