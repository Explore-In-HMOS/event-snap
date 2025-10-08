import { EventModel } from '../model/EventModel'
import { events } from './mockdata'

export class EventService {

  static getNearbyEvents(): EventModel[] {
    return [...events]
  }

  static toggleFavorite(id: number) {
    const event = events.find(e => e.id === id)
    if (event) {event.favorite = !event.favorite}
  }

  static findEventByQr(qrCode: string): EventModel | undefined {
    return events.find(e => e.qrCode === qrCode)
  }
}