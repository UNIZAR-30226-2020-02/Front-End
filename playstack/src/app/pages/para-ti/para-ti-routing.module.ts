import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ParaTiPage } from './para-ti.page';

const routes: Routes = [
  {
    path: '',
    component: ParaTiPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ParaTiPageRoutingModule {}
