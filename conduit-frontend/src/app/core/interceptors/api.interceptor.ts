import { Injectable } from "@angular/core";
import {
  HttpEvent,
  HttpInterceptor,
  HttpHandler,
  HttpRequest,
} from "@angular/common/http";
import { Observable } from "rxjs";

@Injectable({ providedIn: "root" })
export class ApiInterceptor implements HttpInterceptor {
  intercept(
    req: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    // const apiReq = req.clone({ url: `https://api.realworld.io/api${req.url}` });
    // const apiReq = req.clone({ url: `http://5.75.162.229:8000/api${req.url}` });
    const apiReq = req.clone({ url: `http://127.0.0.1:8000/api${req.url}` });
    return next.handle(apiReq);
  }
}
