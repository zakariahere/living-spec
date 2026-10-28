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
