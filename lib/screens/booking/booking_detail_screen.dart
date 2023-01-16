import 'package:booking_system_flutter/component/add_review_dialog.dart';
import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/booking_detail_model.dart';
import 'package:booking_system_flutter/model/extra_charges_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/booking_history_component.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_detail_handyman_widget.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_detail_provider_widget.dart';
import 'package:booking_system_flutter/screens/booking/component/countdown_component.dart';
import 'package:booking_system_flutter/screens/booking/component/price_common_widget.dart';
import 'package:booking_system_flutter/screens/booking/component/reason_dialog.dart';
import 'package:booking_system_flutter/screens/booking/component/service_proof_list_widget.dart';
import 'package:booking_system_flutter/screens/booking/handyman_info_screen.dart';
import 'package:booking_system_flutter/screens/booking/provider_info_screen.dart';
import 'package:booking_system_flutter/screens/payment/payment_screen.dart';
import 'package:booking_system_flutter/screens/review/rating_view_all_screen.dart';
import 'package:booking_system_flutter/screens/review/review_widget.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  BookingDetailScreen({required this.bookingId});

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  double totalExtraCharges = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getBookingDetail({CommonKeys.bookingId: widget.bookingId.toString(), CommonKeys.customerId: appStore.userId});
  }

  //region Widgets
  Widget _buildReasonWidget({required BookingDetailResponse snap}) {
    if (((snap.bookingDetail!.status == BookingStatusKeys.cancelled || snap.bookingDetail!.status == BookingStatusKeys.rejected || snap.bookingDetail!.status == BookingStatusKeys.failed) &&
        ((snap.bookingDetail!.reason != null && snap.bookingDetail!.reason!.isNotEmpty))))
      return Container(
        padding: EdgeInsets.all(16),
        color: redColor.withOpacity(0.05),
        width: context.width(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.lblReasonCancelling, style: secondaryTextStyle()),
            Text(snap.bookingDetail!.reason.validate(), style: primaryTextStyle(color: redColor)),
          ],
        ),
      );

    return SizedBox();
  }

  Widget _pendingMessage({required BookingDetailResponse snap}) {
    if (snap.bookingDetail!.status == BookingStatusKeys.pending)
      return Container(
        padding: EdgeInsets.all(16),
        color: redColor.withOpacity(0.08),
        width: context.width(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.lblWaitingForProviderApproval, style: primaryTextStyle(color: redColor, size: 16)),
          ],
        ),
      );

    return SizedBox();
  }

  Widget bookingIdWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          language.lblBookingID,
          style: boldTextStyle(size: LABEL_TEXT_SIZE, color: appStore.isDarkMode ? white : gray.withOpacity(0.8)),
        ),
        Text('#' + widget.bookingId.validate().toString(), style: boldTextStyle(color: primaryColor, size: LABEL_TEXT_SIZE)),
      ],
    );
  }

  Widget buildTimeWidget({required BookingData bookingDetail}) {
    if (bookingDetail.booking_slot == null) {
      return Text(formatDate(bookingDetail.date.validate(), format: HOUR_12_FORMAT), style: boldTextStyle(size: 14));
    }
    return Text(TimeOfDay(hour: bookingDetail.booking_slot.validate().splitBefore(':').split(":").first.toInt(), minute: bookingDetail.booking_slot.validate().splitBefore(':').split(":").last.toInt()).format(context), style: boldTextStyle(size: 14));
  }

  Widget serviceDetailWidget({required BookingData bookingDetail, required ServiceData serviceDetail}) {
    return GestureDetector(
      onTap: () {
        if (bookingDetail.isPostJob) {
          //
        } else {
          ServiceDetailScreen(serviceId: bookingDetail.serviceId.validate()).launch(context);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bookingDetail.serviceName.validate(), style: boldTextStyle(size: 20)),
              16.height,
              Row(
                children: [
                  Text("${language.lblDate}: ", style: secondaryTextStyle()),
                  if (bookingDetail.date.validate().isNotEmpty) Text(formatDate(bookingDetail.date.validate(), format: DATE_FORMAT_2), style: boldTextStyle(size: 14)),
                ],
              ).visible(bookingDetail.date.validate().isNotEmpty),
              8.height,
              Row(
                children: [
                  Text("${language.lblTime}: ", style: secondaryTextStyle()),
                  if (bookingDetail.date.validate().isNotEmpty) buildTimeWidget(bookingDetail: bookingDetail),
                ],
              ).visible(bookingDetail.date.validate().isNotEmpty),
            ],
          ).expand(),
          if (serviceDetail.attachments!.isNotEmpty)
            CachedImageWidget(
              url: serviceDetail.attachments!.first,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              radius: 8,
            ),
        ],
      ),
    );
  }

  Widget counterWidget({required BookingDetailResponse value}) {
    if (value.bookingDetail!.isHourlyService &&
        (value.bookingDetail!.status == BookingStatusKeys.inProgress || value.bookingDetail!.status == BookingStatusKeys.hold || value.bookingDetail!.status == BookingStatusKeys.complete || value.bookingDetail!.status == BookingStatusKeys.onGoing))
      return Column(
        children: [
          16.height,
          CountdownWidget(bookingDetailResponse: value),
        ],
      );
    else
      return Offstage();
  }

  Widget serviceProofListWidget({required List<ServiceProof> list}) {
    if (list.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(language.lblServiceProof, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: ListView.separated(
            itemBuilder: (context, index) => ServiceProofListWidget(data: list[index]),
            itemCount: list.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget handymanWidget({required List<UserData> handymanList, required ServiceData serviceDetail, required BookingData bookingDetail}) {
    if (handymanList.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language.lblAboutHandyman, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Column(
          children: handymanList.map((e) {
            return BookingDetailHandymanWidget(
              handymanData: e,
              serviceDetail: serviceDetail,
              bookingDetail: bookingDetail,
              onUpdate: () {
                setState(() {});
              },
            ).onTap(
              () {
                HandymanInfoScreen(handymanId: e.id).launch(context).then((value) => null);
              },
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget providerWidget({required BookingDetailResponse res}) {
    if (res.providerData == null) return Offstage();
    bool canCustomerContact = res.bookingDetail!.status != BookingStatusKeys.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language.lblAboutProvider, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        BookingDetailProviderWidget(providerData: res.providerData!, canCustomerContact: canCustomerContact).onTap(
          () {
            ProviderInfoScreen(providerId: res.providerData!.id.validate(), canCustomerContact: canCustomerContact).launch(context);
          },
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
      ],
    );
  }

  Widget extraChargesWidget({required List<ExtraChargesModel> extraChargesList}) {
    if (extraChargesList.isEmpty) return Offstage();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language.extraCharges, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: radius()),
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: extraChargesList.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) {
              ExtraChargesModel data = extraChargesList[i];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(data.title.validate(), style: secondaryTextStyle(size: 16)).expand(),
                      16.width,
                      Row(
                        children: [
                          Text('${data.qty} * ${data.price.validate()} = ', style: secondaryTextStyle()),
                          4.width,
                          PriceWidget(price: '${data.price.validate() * data.qty.validate()}'.toDouble(), size: 18, color: textPrimaryColorGlobal, isBoldText: true),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget paymentDetailCard(BookingData bookingData) {
    if (bookingData.paymentId != null && bookingData.paymentStatus != null)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          ViewAllLabel(label: language.paymentDetail, list: []),
          8.height,
          Container(
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.lblId, style: secondaryTextStyle(size: 16)),
                    Text("#" + bookingData.paymentId.toString(), style: boldTextStyle()),
                  ],
                ),
                4.height,
                Divider(),
                4.height,
                if (bookingData.paymentMethod.validate().isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.lblMethod, style: secondaryTextStyle(size: 16)),
                      Text(
                        (bookingData.paymentMethod != null ? bookingData.paymentMethod.toString() : language.notAvailable).capitalizeFirstLetter(),
                        style: boldTextStyle(),
                      ),
                    ],
                  ),
                4.height,
                Divider().visible(bookingData.paymentMethod != null),
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.lblStatus, style: secondaryTextStyle(size: 16)),
                    Text(
                      bookingData.paymentStatus.validate(value: language.lblPending).capitalizeFirstLetter(),
                      style: boldTextStyle(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

    return Offstage();
  }

  Widget customerReviewWidget({required List<RatingData> ratingList, required RatingData? customerReview, required BookingData bookingDetail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bookingDetail.status == BookingStatusKeys.complete && bookingDetail.paymentStatus == SERVICE_PAYMENT_STATUS_PAID)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              24.height,
              if (customerReview == null)
                Text(language.lblNotRatedYet, style: boldTextStyle(size: LABEL_TEXT_SIZE))
              else
                Row(
                  children: [
                    16.height,
                    Text(language.yourReview, style: boldTextStyle(size: LABEL_TEXT_SIZE)).expand(),
                    ic_edit_square.iconImage(size: 16).paddingAll(8).onTap(() {
                      showInDialog(
                        context,
                        contentPadding: EdgeInsets.zero,
                        builder: (p0) {
                          return AddReviewDialog(customerReview: customerReview);
                        },
                      ).then((value) {
                        if (value ?? false) {
                          setState(() {});
                        }
                      }).catchError((e) {
                        toast(e.toString());
                      });
                    }),
                    ic_delete.iconImage(size: 16).paddingAll(8).onTap(() {
                      deleteDialog(context, onSuccess: () async {
                        appStore.setLoading(true);

                        await deleteReview(id: customerReview.id.validate()).then((value) {
                          toast(value.message);
                        }).catchError((e) {
                          toast(e.toString());
                        });

                        setState(() {});

                        appStore.setLoading(false);
                      }, title: language.lblDeleteReview, subTitle: language.lblConfirmReviewSubTitle);
                      return;
                    }),
                  ],
                ),
              16.height,
              if (customerReview == null)
                AppButton(
                  color: context.primaryColor,
                  onTap: () {
                    showInDialog(
                      context,
                      contentPadding: EdgeInsets.zero,
                      builder: (p0) {
                        return AddReviewDialog(serviceId: bookingDetail.serviceId.validate(), bookingId: bookingDetail.id.validate());
                      },
                    ).then((value) {
                      if (value) {
                        setState(() {});
                      }
                    }).catchError((e) {
                      log(e.toString());
                    });
                  },
                  text: language.btnRate,
                  textColor: Colors.white,
                ).withWidth(context.width())
              else
                ReviewWidget(data: customerReview),
            ],
          ),
        16.height,
        if (ratingList.isNotEmpty)
          ViewAllLabel(
            label: language.review,
            list: ratingList,
            onTap: () {
              RatingViewAllScreen(ratingData: ratingList, serviceId: bookingDetail.serviceId).launch(context);
            },
          ),
        8.height,
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: ratingList.length,
          itemBuilder: (context, index) => ReviewWidget(data: ratingList[index]),
        ),
      ],
    );
  }

  Widget descriptionWidget({required BookingDetailResponse value}) {
    if (value.bookingDetail!.description.validate().isNotEmpty)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Text("${language.booking.split('s').join(' ')}${language.hintDescription}", style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          8.height,
          ReadMoreText(
            value.bookingDetail!.description.validate(),
            style: secondaryTextStyle(),
          )
        ],
      );
    else
      return Offstage();
  }

  Widget myServiceList({required List<ServiceData> serviceList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language.myServices, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        8.height,
        AnimatedListView(
          itemCount: serviceList.length,
          shrinkWrap: true,
          itemBuilder: (_, i) {
            ServiceData data = serviceList[i];

            return Container(
              width: context.width(),
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: BorderRadius.all(Radius.circular(defaultRadius))),
              child: Row(
                children: [
                  CachedImageWidget(
                    url: data.attachments.validate().isNotEmpty ? data.attachments!.first.validate() : "",
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                    radius: defaultRadius,
                  ),
                  16.width,
                  Text(data.name.validate(), style: primaryTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _action({required BookingDetailResponse bookingResponse}) {
    if (bookingResponse.bookingDetail!.status == BookingStatusKeys.pending || bookingResponse.bookingDetail!.status == BookingStatusKeys.accept) {
      return AppButton(
        text: language.lblCancelBooking,
        textColor: Colors.white,
        color: primaryColor,
        onTap: () {
          _handleCancelClick(status: bookingResponse);
        },
      ).paddingOnly(left: 16, right: 16, bottom: 16);
    } else if (bookingResponse.bookingDetail!.status == BookingStatusKeys.onGoing) {
      return AppButton(
        text: language.lblStart,
        textColor: Colors.white,
        color: Colors.green,
        onTap: () {
          _handleStartClick(status: bookingResponse);
        },
      ).paddingOnly(left: 16, right: 16, bottom: 16);
    } else if (bookingResponse.bookingDetail!.status == BookingStatusKeys.inProgress) {
      return Row(
        children: [
          AppButton(
            text: language.lblHold,
            textColor: Colors.white,
            color: hold,
            onTap: () {
              _handleHoldClick(status: bookingResponse);
            },
          ).expand(),
          16.width,
          AppButton(
            text: language.done,
            textColor: Colors.white,
            color: primaryColor,
            onTap: () {
              _handleDoneClick(status: bookingResponse);
            },
          ).expand(),
        ],
      ).paddingOnly(left: 16, right: 16, bottom: 16);
    } else if (bookingResponse.bookingDetail!.status == BookingStatusKeys.hold) {
      return Row(
        children: [
          AppButton(
            text: language.lblResume,
            textColor: Colors.white,
            color: primaryColor,
            onTap: () {
              _handleResumeClick(status: bookingResponse);
            },
          ).expand(),
          16.width,
          AppButton(
            text: language.lblCancel,
            textColor: Colors.white,
            color: cancelled,
            onTap: () {
              _handleCancelClick(status: bookingResponse);
            },
          ).expand(),
        ],
      ).paddingOnly(left: 16, right: 16, bottom: 16);
    } else if (bookingResponse.bookingDetail!.status == BookingStatusKeys.pendingApproval) {
      return Container(
        width: context.width(),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: context.cardColor),
        child: Text(language.lblWaitingForResponse, style: boldTextStyle()).center(),
      );
    } else if (bookingResponse.bookingDetail!.status == BookingStatusKeys.complete && bookingResponse.bookingDetail!.type != SERVICE_TYPE_FREE && (bookingResponse.bookingDetail!.paymentStatus == null)) {
      return AppButton(
        text: language.lblPayNow,
        textColor: Colors.white,
        color: Colors.green,
        onTap: () {
          PaymentScreen(bookings: bookingResponse).launch(context);
        },
      ).paddingOnly(left: 16, right: 16, bottom: 16);
    }

    return SizedBox();
  }

  //endregion

  //region ActionMethods
  //region Cancel
  void _handleCancelClick({required BookingDetailResponse status}) {
    if (status.bookingDetail!.status == BookingStatusKeys.pending || status.bookingDetail!.status == BookingStatusKeys.accept || status.bookingDetail!.status == BookingStatusKeys.hold) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        builder: (context) {
          return AppCommonDialog(
            title: language.lblCancelReason,
            child: ReasonDialog(status: status),
          );
        },
      ).then((value) {
        if (value != null) {
          setState(() {});
        }
      });
    }
  }

  //endregion

  //region Hold Click
  void _handleHoldClick({required BookingDetailResponse status}) {
    if (status.bookingDetail!.status == BookingStatusKeys.inProgress) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        backgroundColor: context.scaffoldBackgroundColor,
        builder: (context) {
          return AppCommonDialog(
            title: language.lblConfirmService,
            child: ReasonDialog(status: status, currentStatus: BookingStatusKeys.hold),
          );
        },
      ).then((value) {
        if (value != null) {
          setState(() {});
        }
      });
    }
  }

  //endregion

  //region Resume Service
  void _handleResumeClick({required BookingDetailResponse status}) {
    showConfirmDialogCustom(
      context,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      negativeText: language.lblNo,
      positiveText: language.lblYes,
      title: language.lblConFirmResumeService,
      onAccept: (c) {
        resumeClick(status: status);
      },
    );
  }

  void resumeClick({required BookingDetailResponse status}) async {
    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: formatDate(DateTime.now().toString(), format: BOOKING_SAVE_FORMAT),
      BookingUpdateKeys.endAt: status.bookingDetail!.endAt.validate(),
      BookingUpdateKeys.durationDiff: status.bookingDetail!.durationDiff.validate(),
      BookingUpdateKeys.reason: "",
      CommonKeys.status: BookingStatusKeys.inProgress,
    };

    log("req $request");
    appStore.setLoading(true);

    await updateBooking(request).then((res) async {
      toast(res.message!);

      commonStartTimer(isHourlyService: status.bookingDetail!.isHourlyService, status: BookingStatusKeys.inProgress, timeInSec: status.bookingDetail!.durationDiff.validate().toInt());
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  //endregion

  //region Start Service
  void startClick({required BookingDetailResponse status}) async {
    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: formatDate(DateTime.now().toString(), format: BOOKING_SAVE_FORMAT),
      BookingUpdateKeys.endAt: status.bookingDetail!.endAt.validate(),
      BookingUpdateKeys.durationDiff: 0,
      BookingUpdateKeys.reason: "",
      CommonKeys.status: BookingStatusKeys.inProgress,
    };

    log("req $request");
    appStore.setLoading(true);

    await updateBooking(request).then((res) async {
      toast(res.message!);
      commonStartTimer(isHourlyService: status.bookingDetail!.isHourlyService, status: BookingStatusKeys.inProgress, timeInSec: status.bookingDetail!.durationDiff.validate().toInt());

      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  void _handleStartClick({required BookingDetailResponse status}) {
    showConfirmDialogCustom(
      context,
      title: language.confirmationRequestTxt,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      negativeText: language.lblNo,
      positiveText: language.lblYes,
      onAccept: (c) {
        startClick(status: status);
      },
    );
  }

  //endregion

  //region Done Service
  void doneClick({required BookingDetailResponse status}) async {
    String endDateTime = DateFormat(BOOKING_SAVE_FORMAT).format(DateTime.now());

    num durationDiff = DateTime.parse(endDateTime.validate()).difference(DateTime.parse(status.bookingDetail!.startAt.validate())).inSeconds;

    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: status.bookingDetail!.startAt.validate(),
      BookingUpdateKeys.endAt: endDateTime,
      BookingUpdateKeys.durationDiff: durationDiff,
      BookingUpdateKeys.reason: DONE,
      CommonKeys.status: BookingStatusKeys.pendingApproval,
    };

    log("req $request");
    appStore.setLoading(true);

    await updateBooking(request).then((res) async {
      toast(res.message!);
      commonStartTimer(isHourlyService: status.bookingDetail!.isHourlyService, status: BookingStatusKeys.complete, timeInSec: status.bookingDetail!.durationDiff.validate().toInt());
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  void _handleDoneClick({required BookingDetailResponse status}) {
    showConfirmDialogCustom(
      context,
      negativeText: language.lblNo,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      title: language.lblEndServicesMsg,
      positiveText: language.lblYes,
      onAccept: (c) {
        doneClick(status: status);
      },
    );
  }

  //endregion

  //region Methods
  void commonStartTimer({required bool isHourlyService, required String status, required int timeInSec}) {
    if (isHourlyService) {
      Map<String, dynamic> liveStreamRequest = {
        "inSeconds": timeInSec,
        "status": status,
      };
      LiveStream().emit(LIVESTREAM_START_TIMER, liveStreamRequest);
    }
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<BookingDetailResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Stack(
              children: [
                AnimatedScrollView(
                  padding: EdgeInsets.only(bottom: 60),
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildReasonWidget(snap: snap.data!),
                    _pendingMessage(snap: snap.data!),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          8.height,
                          bookingIdWidget(),
                          Divider(height: 32),

                          /// Service Details
                          serviceDetailWidget(bookingDetail: snap.data!.bookingDetail!, serviceDetail: snap.data!.service!),
                          16.height,
                          Divider(height: 0),

                          /// Service Counter Time Widget
                          counterWidget(value: snap.data!),

                          /// My Service List
                          if (snap.data!.postRequestDetail != null && snap.data!.postRequestDetail!.service != null) myServiceList(serviceList: snap.data!.postRequestDetail!.service!),

                          /// Description
                          descriptionWidget(value: snap.data!),

                          /// Service Proof
                          serviceProofListWidget(list: snap.data!.serviceProof.validate()),

                          /// About Handyman Card
                          handymanWidget(handymanList: snap.data!.handymanData.validate(), serviceDetail: snap.data!.service!, bookingDetail: snap.data!.bookingDetail!),

                          /// About Provider Card
                          providerWidget(res: snap.data!),

                          /// Extra charges
                          extraChargesWidget(extraChargesList: snap.data!.bookingDetail!.extraCharges.validate()),
                          8.height,

                          /// Price Details
                          PriceCommonWidget(
                            bookingDetail: snap.data!.bookingDetail!,
                            serviceDetail: snap.data!.service!,
                            taxes: snap.data!.bookingDetail!.taxes.validate(),
                            couponData: snap.data!.couponData,
                          ),

                          /// Payment Detail Card
                          if (snap.data!.service!.type.validate() != SERVICE_TYPE_FREE) paymentDetailCard(snap.data!.bookingDetail!),

                          /// Customer Review widget
                          customerReviewWidget(ratingList: snap.data!.ratingData.validate(), customerReview: snap.data!.customerReview, bookingDetail: snap.data!.bookingDetail!),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(bottom: 0, left: 0, right: 0, child: _action(bookingResponse: snap.data!))
              ],
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading))
          ],
        );
      }
      return LoaderWidget().center();
    }

    return FutureBuilder<BookingDetailResponse>(
      future: getBookingDetail({CommonKeys.bookingId: widget.bookingId.toString(), CommonKeys.customerId: appStore.userId}),
      builder: (context, snap) {
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            return await 2.seconds.delay;
          },
          child: Scaffold(
            appBar: appBarWidget(
              snap.hasData ? snap.data!.bookingDetail!.statusLabel.validate() : "",
              color: context.primaryColor,
              textColor: Colors.white,
              showBack: true,
              backWidget: BackWidget(),
              actions: [
                if (snap.hasData)
                  TextButton(
                    child: Text(language.lblCheckStatus, style: primaryTextStyle(color: Colors.white)),
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
                        builder: (_) {
                          return DraggableScrollableSheet(
                            initialChildSize: 0.50,
                            minChildSize: 0.2,
                            maxChildSize: 1,
                            builder: (context, scrollController) => BookingHistoryComponent(data: snap.data!.bookingActivity!.reversed.toList(), scrollController: scrollController),
                          );
                        },
                      );
                    },
                  ).paddingRight(16)
              ],
            ),
            body: buildBodyWidget(snap),
          ),
        );
      },
    );
  }
}
