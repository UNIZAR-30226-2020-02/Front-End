import { async, ComponentFixture, TestBed } from '@angular/core/testing';
import { IonicModule } from '@ionic/angular';

import { ParaTiPage } from './para-ti.page';

describe('ParaTiPage', () => {
  let component: ParaTiPage;
  let fixture: ComponentFixture<ParaTiPage>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ParaTiPage ],
      imports: [IonicModule.forRoot()]
    }).compileComponents();

    fixture = TestBed.createComponent(ParaTiPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  }));

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
