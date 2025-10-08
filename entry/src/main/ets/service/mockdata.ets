import { EventModel } from '../model/EventModel';

export const events : Array<EventModel> = [
  {
    id: 1,
    title: 'Mini Konser',
    location: 'Kültür Park',
    time: '18:00',
    qrCode: 'QR12345',
    favorite: false
  },
  {
    id: 2,
    title: 'Workshop: Fotoğraf',
    location: 'Sanat Merkezi',
    time: '14:30',
    qrCode: 'QR67890',
    favorite: false
  },
  {
    id: 3,
    title: 'Stand-Up Gösterisi',
    location: 'Kafe Lounge',
    time: '20:00',
    qrCode: 'QR54321',
    favorite: false
  }
];