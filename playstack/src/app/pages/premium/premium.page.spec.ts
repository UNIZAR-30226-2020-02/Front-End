import { async, ComponentFixture, TestBed } from '@angular/core/testing';
import { IonicModule } from '@ionic/angular';

import { PremiumPage } from './premium.page';

describe('PremiumPage', () => {
  let component: PremiumPage;
  let fixture: ComponentFixture<PremiumPage>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PremiumPage ],
      imports: [IonicModule.forRoot()]
    }).compileComponents();

    fixture = TestBed.createComponent(PremiumPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  }));

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
