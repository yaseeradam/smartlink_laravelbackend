<?php

namespace App\Domain\Dispatch\Controllers;

use App\Domain\Dispatch\Resources\DispatchOfferResource;
use App\Domain\Dispatch\Services\DispatchService;
use Illuminate\Http\Request;

class RiderDispatchController
{
    public function __construct(private readonly DispatchService $dispatchService)
    {
    }

    public function offers(Request $request)
    {
        $offers = $this->dispatchService->offersForRider($request->user());

        return DispatchOfferResource::collection($offers);
    }

    public function accept(Request $request, int $offerId)
    {
        try {
            $job = $this->dispatchService->acceptOffer($request->user(), $offerId);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 409);
        }

        return response()->json([
            'dispatch_job_id' => $job->id,
            'status' => $job->status->value,
            'assigned_rider_user_id' => $job->assigned_rider_user_id,
        ]);
    }

    public function decline(Request $request, int $offerId)
    {
        try {
            $offer = $this->dispatchService->declineOffer($request->user(), $offerId);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 409);
        }

        return new DispatchOfferResource($offer->load('job.order'));
    }
}

